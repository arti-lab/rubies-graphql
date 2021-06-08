class Mutations::CreatePlayground < Mutations::BaseMutation
  null false
  argument :name, String, required: true
  argument :description, String, required: false
  argument :creator_username, String, required: false

  field :playground, Types::PlaygroundType, null: true
  field :me, Types::UserType, null: true

  def resolve(
      name:,
      description: nil,
      creator_username: nil
    )
    current_user = context[:current_user]

    creator = current_user
    if current_user.is_visor_admin && creator_username
      # Only allow creation for other users by visor admins
      creator = User.find_by(username: creator_username)
    end

    if creator.blank?
      return {
        playground: nil,
        me: nil,
        errors: ["Could not find a user by that username"],
      }
    end

    avatar_img = context[:file]
    begin
      img_url = nil
      if !avatar_img.blank?
        bucket = Aws::S3::Resource.new.bucket(AwsConstants::S3::DEFAULT_BUCKET)
        obj = bucket.put_object(
          acl: "public-read",
          key: "avatar_img/#{SecureRandom.hex}.png",
          body: avatar_img,
        )
        img_url = obj.public_url
      end

      playground = Playground.new(
        name: name,
        description: description,
        avatar_url: img_url,
        creator: creator,
      )
      if playground.save
        playground.add_member(creator)
        return {
          playground: playground,
          me: current_user,
          errors: [],
        }
      else
        return {
          playground: nil,
          me: nil,
          errors: playground.errors.full_messages
        }
      end
    rescue => e
      Rails.logger.fatal("Mutations::CreatePlayground: #{e.message}")
      return {
        playground: nil,
        me: nil,
        errors: ["Unable to create playground"]
      }
    end
  end
end
