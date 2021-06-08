class Mutations::RemoveModerator < Mutations::BaseMutation
  null false

  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType
  argument :user, ID, required: true, loads: Types::UserType

  field :contest_template, Types::ContestTemplateType, null: true
  field :user, Types::UserType, null: true
  field :me, Types::UserType, null: false

  def resolve(contest_template:, user:)
    current_user = context[:current_user]
    raise "Error" if !current_user

    if contest_template.can_edit?(current_user)
      if contest_template.has_moderator?(user)
        begin
          contest_template.remove_moderator(user)
          errors = []
        rescue StandardError => e
          errors = ["Unable to remove moderator \"#{user.id}\" from contest template \"#{contest_template.id}\""]
        end
        return {
            contest_template: contest_template,
            user: user,
            me: current_user,
            errors: errors
        }

      else
        return {
            contest_template: nil,
            user: user,
            me: current_user,
            errors: ["User \"#{user.id}\" is not a moderator for contest template \"#{contest_template.id}\""]
        }
      end
    else
      return {
          contest_template: nil,
          user: user,
          me: current_user,
          errors: ["Permission denied for removing moderator \"#{user.id}\" from contest template \"#{contest_template.id}\""]
      }
    end
  end

end
