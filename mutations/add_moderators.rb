class Mutations::AddModerators < Mutations::BaseMutation
  null false

  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType
  argument :user_slugs, [String], required: true

  field :contest_template, Types::ContestTemplateType, null: true
  field :users, [Types::UserType], null: true
  field :me, Types::UserType, null: false

  def resolve(contest_template:, user_slugs:)
    current_user = context[:current_user]
    raise "Error" if !current_user

    successfully_added_users = []
    if contest_template.can_edit?(current_user)
      ActiveRecord::Base.transaction do
        user_slugs.each do |s|
          user = User.friendly.find(s)
          if contest_template.has_moderator?(user)
            return {
              contest_template: nil,
              users: nil,
              me: current_user,
              errors: ["User \"#{user.id}\" is already a moderator for contest template \"#{contest_template.id}\""]
            }
          else
            begin
              contest_template.add_moderator(user)
            rescue StandardError => e
              return {
                contest_template: nil,
                users: nil,
                me: current_user,
                errors: ["Unable to add moderator \"#{user.id}\" to contest template \"#{contest_template.id}\""]
              }
            end
          end
          successfully_added_users.push(user)
        end
      end
    else
      return {
          contest_template: nil,
          users: nil,
          me: current_user,
          errors: ["Permission denied for adding moderator \"#{user.id}\" to contest template \"#{contest_template.id}\""]
      }
    end
    return {
        contest_template: contest_template,
        users: successfully_added_users,
        me: current_user,
        errors: [],
    }
  end
end
