class Mutations::CreateEventParty < Mutations::BaseMutation
  null false
  argument :contest, ID, required: true, loads: Types::ContestType

  field :event_party, Types::EventPartyType, null: true
  field :contest, Types::ContestType, null: true

  def resolve(contest:)
    current_user = context[:current_user]
    raise "Error" if !current_user
    contest_participant = ContestParticipant.find_by(participant: current_user, contest: contest)
    if contest_participant.blank?
      return {
        event_party: nil,
        contest: nil,
        errors: ["Couldn't find contest participant"],
      }
    end
    if !contest_participant.current_party.blank?
      return {
        event_party: nil,
        contest: nil,
        errors: ["Current user already in party"],
      }
    end
    begin
      event_party = EventParty.new(
        leader: contest_participant,
        contest: contest
      )
      if event_party.save
        event_party.add_member(contest_participant)
        return {
          event_party: event_party,
          contest: contest,
          errors: [],
        }
      else
        return {
          event_party: nil,
          contest: nil,
          errors: event_party.errors.full_messages
        }
      end
    rescue => e
      Rails.logger.fatal("Mutations::CreateEventParty: #{e.message}")
      return {
        event_party: nil,
        contest: nil,
        errors: ["Unable to create event party"]
      }
    end
  end
end