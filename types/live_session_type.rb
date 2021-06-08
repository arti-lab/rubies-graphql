class Types::LiveSessionType < Types::BaseObject
  field :game, String, null: true
  field :host, Types::UserType, null: false,
    resolve: ->(obj, args, ctx) {
      obj.user
    }

  field :title, String, null: true
  field :start_time, Types::Filter::Common::DateTime, null: false
  field :end_time, Types::Filter::Common::DateTime, null: false
  field :created_at, Types::Filter::Common::DateTime, null: false
  field :updated_at, Types::Filter::Common::DateTime, null: false
  field :active_attendees, [Types::UserType], null: false

  connection :attendances, Connections::LiveSessionAttendancesConnection

  def get_record_id(object)
    object.friendly_id
  end

  private
end
