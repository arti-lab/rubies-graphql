class Mutations::EndContest < Mutations::BaseMutation
  null false
  argument :contest, ID, required: true, loads: Types::ContestType

  field :contest, Types::ContestType, null: true

  def resolve(contest:)
    current_user = context[:current_user]
    raise "Error" if !current_user
    if !contest.contest_template.can_edit?(current_user)
      return {
        contest: nil,
        errors: ["User does not have permission to end contest"]
      }
    end
    ActiveRecord::Base.transaction do
      contest.award_contest_badges
      contest.end_contest
      contest.contest_template.create_next_contest_occurrence
    end
    return {
      contest: contest,
      errors: [],
    }
  end
end

