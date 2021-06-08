class Mutations::FollowContest < Mutations::BaseMutation
  null false

  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType

  field :contest_template, Types::ContestTemplateType, null: true
  field :me, Types::UserType, null: false

  def resolve(contest_template:)
    follower = context[:current_user]
    if follower.following_contest?(contest_template)
      return {
        contest_template: nil,
        me: follower,
        errors: ["User already following contest template \"#{contest_template.id}\""]
      }
    else
      begin
        follower.follow_contest(contest_template)
        ContestFollow.find_by(user: follower, contest_template: contest_template).notify
        errors = []
      rescue StandardError, RecordNotFound => e
        errors = ["Unable to follow contest template=\"#{contest_template.id}\""]
      end
      return {
        contest_template: contest_template,
        me: follower,
        errors: errors
      }
    end
  end

end
