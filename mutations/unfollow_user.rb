class Mutations::UnfollowUser < Mutations::BaseMutation
  null false

  argument :followee, ID, required: true, loads: Types::UserType

  field :user, Types::UserType, null: true
  field :me, Types::UserType, null: false

  def resolve(followee:)
    unfollower = context[:current_user]
    begin
      unfollower.unfollow(followee)
    rescue StandardError => e
      errors = ["Cannot unfollow user=\"#{followee.id}\""]
    end

    if unfollower.following?(followee)
      return {
        user: nil,
        me: unfollower,
        errors: errors
      }
    else
      return {
        user: followee,
        me: unfollower,
        errors: []
      }
    end
  end

end
