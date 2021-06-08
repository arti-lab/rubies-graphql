class Mutations::JoinContest < Mutations::BaseMutation
  null false
  argument :contest, ID, required: true, loads: Types::ContestType

  field :contest, Types::ContestType, null: true

  def resolve(contest:)
    current_user = context[:current_user]
    raise "Error" if !current_user

    begin
      contest_participant = ContestParticipant.find_by(contest: contest, participant: current_user)
      team_names = contest.team_names
      if contest_participant.blank?
        if team_names.empty?
          contest_participant = ContestParticipant.create(contest: contest, participant: current_user)
        else
          team = team_names.sample
          contest_participant = ContestParticipant.create(contest: contest, participant: current_user, team: team)
        end
      else
        contest_participant.touch
      end
      return {
        contest: contest,
        errors: []
      }
    rescue => e
      Rails.logger.error("Unable to join contest #{contest.slug}: #{e.message}")
      return {
        contest: nil,
        errors: ["Unable to join contest #{contest.slug}"]
      }
    end
  end
end
