class Mutations::UploadAvatar < Mutations::BaseMutation
  null false

  argument :user, ID, required: true, loads: Types::UserType

  field :user, Types::UserType, null: true

  def resolve(user:)
    raise "Invalid permissions" if user != context[:current_user]

    bucket = Aws::S3::Resource.new.bucket(AwsConstants::S3::DEFAULT_BUCKET)
    obj = bucket.put_object(
      acl: "public-read",
      key: "avatars/#{user.slug}/#{SecureRandom.hex}.png",
      body: context[:file],
    )
    old_avatar_uri = URI(user.avatar_url)
    user.avatar_url = obj.public_url
    user.save!

    # delete old avatar
    if (
      old_avatar_uri.host.include?(AwsConstants::S3::DEFAULT_BUCKET) &&
      !user.avatar_url.include?("defaults")
    )
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

    return {
      user: user,
      errors: []
    }
  end
end
