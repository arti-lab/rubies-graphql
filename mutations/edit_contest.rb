class Mutations::EditContest < Mutations::BaseMutation
  null false
  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType
  argument :name, String, required: false
  argument :description, String, required: false
  argument :duration_sec, Int, required: false
  argument :host_username, String, required: false
  argument :scheduled_start_time, Int, required: false
  argument :is_featured, Boolean, required: false
  argument :rules_md, String, required: false
  argument :prizes_md, String, required: false
  argument :prizes_desc_short_md, String, required: false
  argument :splash_img_url, String, required: false
  argument :format_desc_short_md, String, required: false
  argument :config, GraphQL::Types::JSON, required: false
  argument :recurrence, String, required: false
  argument :host_slug, String, required: false
  argument :game_slug, String, required: false

  field :contest, Types::ContestType, null: true

  def resolve(
      contest_template:,
      name: nil,
      description: nil,
      duration_sec: nil,
      scheduled_start_time: nil,
      rules_md: nil,
      prizes_md: nil,
      prizes_desc_short_md: nil,
      splash_img_url: nil,
      format_desc_short_md: nil,
      config: nil,
      recurrence: nil,
      host_username: nil,
      is_featured: false,
      host_slug: nil,
      game_slug: nil
    )
    current_user = context[:current_user]

    raise "Error" if !current_user || !contest_template.can_edit?(current_user)

    splash_img = context[:file]
    begin
      if !splash_img.blank?
        begin
          bucket = Aws::S3::Resource.new.bucket(AwsConstants::S3::DEFAULT_BUCKET)
          obj = bucket.put_object(
            acl: "public-read",
            key: "splash_images/#{SecureRandom.hex}.png",
            body: splash_img,
          )
          splash_img_url = obj.public_url
          if !contest_template.splash_img_url.blank?
            old_splash_img_uri = URI(contest_template.splash_img_url)
            if old_splash_img_uri.host.include?(AwsConstants::S3::DEFAULT_BUCKET)
              bucket.delete_objects(
                delete: {
                  objects: [
                    {
                      key: old_splash_img_uri.path[1..-1],
                    },
                  ],
                },
              )
            end
          end
        rescue => e
          Rails.logger.fatal("EditContestMutation: #{e.class.name} > #{e.message}")
          splash_img_url = contest_template.splash_img_url
        end
      end
      # validate recurrence string
      recurrence = (recurrence || "").gsub(/^RRULE:/, '')

      host = nil
      if !host_slug.nil?
        host = User.friendly.find(host_slug)
      end

      if !scheduled_start_time.nil?
        scheduled_start_time = Time.at(scheduled_start_time/1000)
      end

      game = contest_template.game
      if (!game_slug.blank?)
        game = Game.find_by(slug: game_slug)
        raise "Invalid Game Error" if game.nil?
      end

      fields = {
        name: name,
        description: description,
        duration_sec: duration_sec,
        scheduled_start_time: scheduled_start_time,
        game: game,
        rules_md: rules_md,
        prizes_md: prizes_md,
        prizes_desc_short_md: prizes_desc_short_md,
        splash_img_url: splash_img_url,
        format_desc_short_md: format_desc_short_md,
        config: config,
        recurrence: recurrence,
        host: host,
      }.compact

      updated = contest_template.update(fields)

      if updated
        contest = contest_template.latest_contest_occurrence
        return {
          contest: contest,
          errors: [],
        }
      else
        return {
          contest: nil,
          errors: contest_template.errors.full_messages
        }
      end
    rescue => e
      Rails.logger.fatal("EditContestMutation: #{e.class.name} > #{e.message}")
      return {
        contest: nil,
        errors: ["Unable to edit contest"]
      }
    end
  end
end
