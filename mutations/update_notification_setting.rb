class Mutations::UpdateNotificationSetting < Mutations::BaseMutation
  null false

  argument :contest_change, Boolean, required: false
  argument :contest_doors_open, Boolean, required: false

  field :user, Types::UserType, null: true

  def resolve(
    contest_change: nil,
    contest_doors_open: nil
  )
    current_user = context[:current_user]

    new_fields = {
      contest_change: contest_change,
      contest_doors_open: contest_doors_open,
    }.compact

    if current_user.notification_setting&.update(new_fields)
      return {
        user: current_user,
        errors: [],
      }
    else
      return {
        user: nil,
        errors: current_user.errors.full_messages
      }
    end
  end

end
