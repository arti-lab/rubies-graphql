class Types::AttendanceType < Types::BaseObject
  field :attendee, Types::UserType, null: false
  field :start_time, Types::Filter::Common::DateTime, null: false
  field :end_time, Types::Filter::Common::DateTime, null: false
  field :created_at, Types::Filter::Common::DateTime, null: false
  field :updated_at, Types::Filter::Common::DateTime, null: false

  def get_record_id(object)
    object.friendly_id
  end

  private
end
