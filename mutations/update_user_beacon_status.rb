class Mutations::UpdateUserBeaconStatus < Mutations::BaseMutation
  null false

  argument :user_id, ID, required: true, loads: Types::UserType
  argument :beacon_game, String, required: false
  argument :beacon_status, Types::User::UserBeaconStatus, required: true

  field :user, Types::UserType, null: true

  def resolve(user:, beacon_status:, beacon_game: nil)
    current_user = context[:current_user]
    raise "Error" if current_user != user

    if beacon_status == User::BEACON_STATUS_ONLINE
      StartLiveSessionService.call(user: user, game: beacon_game)
    elsif beacon_status == User::BEACON_STATUS_OFFLINE
      StopLiveSessionService.call(user: user)
    else
      raise "unsupported beacon_status #{beacon_status}"
    end

    {
      user: user,
      errors: [],
    }
  end

end
