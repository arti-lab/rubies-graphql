class Mutations::LeavePlayground < Mutations::BaseMutation
  null false

  argument :playground, ID, required: true, loads: Types::PlaygroundType

  field :playground, Types::PlaygroundType, null: true
  field :me, Types::UserType, null: true

  def resolve(playground:)
    user = context[:current_user]
    if playground.has_member?(user)
      begin
        playground.remove_member(user)
      rescue StandardError => e
        errors = ["Unable to leave playground=\"#{playground.name}\""]
      end
    else
      return {
          playground: nil,
          me: nil,
          errors: ["User not a member of playground \"#{playground.name}\""]
      }
    end
    if !playground.has_member?(user)
      return {
        playground: playground,
        me: user,
        errors: []
      }
    else
      return {
        playground: nil,
        me: nil,
        errors: errors
      }
    end
  end

end
