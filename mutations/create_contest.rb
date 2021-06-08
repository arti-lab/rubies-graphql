class Mutations::CreateContest < Mutations::BaseMutation
  null false
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
  argument :playground, ID, required: true, loads: Types::PlaygroundType
  argument :game_slug, String, required: true

  field :contest, Types::ContestType, null: true

  def resolve(
      name: nil,
      description: nil,
      duration_sec: nil,
      host_username: "",
      scheduled_start_time: nil,
      is_featured: false,
      rules_md: nil,
      prizes_md: nil,
      prizes_desc_short_md: nil,
      splash_img_url: nil,
      format_desc_short_md: nil,
      config: nil,
      recurrence: nil,
      playground: nil,
      game_slug: nil
    )
    current_user = context[:current_user]
    raise "Error" if !current_user
    # Only playground owner and visor admins can create events for playground
    is_owner = current_user == playground.creator
    is_visor_admin = current_user.is_visor_admin
    raise "Permissions Error" if !is_owner && !is_visor_admin
    host = User.find_by(username: host_username)
    if host.blank?
      host = playground.creator
    end
    # Playground owner can only set self or other playground members as event hosts
    raise "Invalid Host Error" unless playground.has_member?(host)

    game = Game.find_by(slug: game_slug)
    raise "Invalid Game Error" if game.nil?

    splash_img = context[:file]
    begin
      if !splash_img.blank?
        bucket = Aws::S3::Resource.new.bucket(AwsConstants::S3::DEFAULT_BUCKET)
        obj = bucket.put_object(
          acl: "public-read",
          key: "splash_images/#{SecureRandom.hex}.png",
          body: splash_img,
        )
        splash_img_url = obj.public_url
      end
      contest_template = ContestTemplate.new(
        name: name,
        description: description,
        duration_sec: duration_sec,
        host: host,
        scheduled_start_time: Time.at(scheduled_start_time/1000), # need to convert to seconds
        is_featured: is_featured,
        rules_md: rules_md,
        prizes_md: prizes_md,
        prizes_desc_short_md: prizes_desc_short_md,
        splash_img_url: splash_img_url,
        format_desc_short_md: format_desc_short_md,
        config: config,
        recurrence: recurrence,
        playground: playground,
        game: game
      )
      if contest_template.save
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
    rescue => exception
      return {
        contest: nil,
        errors: ["Unable to create contest"]
      }
    end
  end
end
