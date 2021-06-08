class Mutations::EditPlayground < Mutations::BaseMutation
  null false
  argument :playground, ID, required: true, loads: Types::PlaygroundType
  argument :name, String, required: true
  argument :description, String, required: false

  field :playground, Types::PlaygroundType, null: true

  def resolve(
    playground:,
    name:,
    description: ""
  )
    current_user = context[:current_user]

    raise "Error" if !current_user || !playground.can_edit?(current_user)
    avatar_img = context[:file]
    avatar_url = playground.avatar_url

    begin
      if !avatar_img.blank?
        begin
          bucket = Aws::S3::Resource.new.bucket(AwsConstants::S3::DEFAULT_BUCKET)
          obj = bucket.put_object(
            acl: "public-read",
            key: "playground_avatars/#{SecureRandom.hex}.png",
            body: avatar_img,
          )
          avatar_url = obj.public_url
          if !playground.avatar_url.blank? && !playground.avatar_url.include?("defaults")
            old_avatar_uri = URI(playground.avatar_url)
            if old_avatar_uri.host.include?(AwsConstants::S3::DEFAULT_BUCKET)
              bucket.delete_objects(
                delete: {
                  objects: [
                    {
                      key: old_avatar_uri.path[1..-1],
                    },
                  ],
                },
              )
            end
          end
        rescue => e
          Rails.logger.fatal("EditPlaygroundMutation: #{e.class.name} > #{e.message}")
          avatar_url = playground.avatar_url
        end
      end
      updated = playground.update(
        name: name,
        description: description,
        avatar_url: avatar_url
      )
      if updated
        return {
          playground: playground,
          errors: [],
        }
      else
        return {
          playground: nil,
          errors: playground.errors.full_messages
        }
      end
    rescue => e
      Rails.logger.fatal("EditPlaygroundMutation: #{e.class.name} > #{e.message}")
      return {
        playground: nil,
        errors: ["Unable to edit playground"]
      }
    end
  end
end
