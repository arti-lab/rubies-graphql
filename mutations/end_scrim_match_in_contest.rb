class Mutations::EndScrimMatchInContest < Mutations::BaseMutation
  null false

  argument :event_party, ID, required: false, loads: Types::EventPartyType
  argument :contest_participant, ID, required: false, loads: Types::ContestParticipantType
  argument :contest, ID, required: true, loads: Types::ContestType

  field :contest, Types::ContestType, null: true

  def resolve(event_party: nil, contest_participant: nil, contest:)
    current_user = context[:current_user]
    raise "Error" if !current_user
    raise "Invalid permissions" if !contest.contest_template.can_edit?(current_user)

    begin
      ActiveRecord::Base.transaction do
        if !event_party.nil?
          contest.add_placement_points_from_winner_killfeed(winner_party: event_party)
        elsif !contest_participant.nil?
          contest.add_placement_points_from_winner_killfeed(winner_participant: contest_participant)
        end
      end
      return {
        contest: contest,
        errors: [],
      }
    rescue => e
      Rails.logger.error("EndScrimMatchInContest: #{e.class.name} > #{e.message}")
      return {
        contest: nil,
        errors: ["Unable to declare winner and add placement points"],
      }
    end
  end

end