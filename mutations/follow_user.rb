class Mutations::FollowUser < Mutations::BaseMutation
  null false

  argument :followee, ID, required: true, loads: Types::UserType

  field :user, Types::UserType, null: true
  field :me, Types::UserType, null: false

  def resolve(followee:)
    follower = context[:current_user]
    begin
      follower.follow(followee)
    rescue StandardError => e
      errors = ["Unable to follow user=\"#{followee.id}\""]
    end

    if follower.following?(followee)
      return {
        user: followee,
        me: follower,
        errors: []
      }
    else
      return {
        user: nil,
        me: follower,
        errors: errors
      }
    end
  end

end
