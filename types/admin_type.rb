class Types::AdminType < Types::UserType
  field :active_sessions, [Types::LiveSessionType], null: false
  field :active_users, [Types::UserType], null: false

  def active_sessions
    LiveSession.where(end_time: nil).order("start_time DESC")
  end

  def active_users
    User.online.order("updated_at DESC")
  end
end
