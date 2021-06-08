class Mutations::UpdateUserBeaconMessage < Mutations::BaseMutation
  null false

  argument :user_id, ID, required: true, loads: Types::UserType
  argument :beacon_message, String, required: true

  field :user, Types::UserType, null: true

  def resolve(user:, beacon_message:)
    current_user = context[:current_user]
    raise "Error" if current_user != user

    UpdateBeaconMessageService.call(user: current_user, beacon_message: beacon_message)

    {
      user: current_user,
      errors: [],
    }
  end
end
