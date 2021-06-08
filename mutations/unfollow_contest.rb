class Mutations::UnfollowContest < Mutations::BaseMutation
  null false

  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType

  field :contest_template, Types::ContestTemplateType, null: true
  field :me, Types::UserType, null: false

  def resolve(contest_template:)
    unfollower = context[:current_user]
    if unfollower.following_contest?(contest_template)
      begin
        unfollower.unfollow_contest(contest_template)
        errors = []
      rescue StandardError => e
        errors = ["Cannot unfollow contest template=\"#{contest_template.id}\""]
      end
      return {
        contest_template: contest_template,
        me: unfollower,
        errors: errors
      }
    else
      return {
        contest_template: nil,
        me: unfollower,
        errors: ["User not following contest template \"#{contest_template.id}\""]
      }
    end
  end

end
