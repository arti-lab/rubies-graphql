class Mutations::RemoveEventPartyMember < Mutations::BaseMutation
  null false
  argument :contest_participant, ID, required: true, loads: Types::ContestParticipantType
  argument :event_party, ID, required: true, loads: Types::EventPartyType

  field :event_party, Types::EventPartyType, null: true
  field :contest, Types::ContestType, null: true

  def resolve(contest_participant:, event_party:)
    current_user = context[:current_user]
    raise "Error" if !current_user
    raise "Invalid Permissions" if current_user != event_party.leader.participant && current_user != contest_participant.participant

    begin
      if contest_participant == event_party.leader
        ActiveRecord::Base.transaction do
          event_party.dissolve_party
        end
        return {
          event_party: event_party,
          contest: event_party.contest,
          errors: [],
        }
      else
        membership = EventPartyMembership.find_by(contest_participant: contest_participant, event_party: event_party)
        if membership.update(is_current: false)
          return {
            event_party: event_party,
            contest: event_party.contest,
            errors: [],
          }
        else
          return {
            event_party: nil,
            contest: nil,
            errors: membership.errors.full_messages,
          }
        end
      end
    rescue => e
      Rails.logger.fatal("Mutations::RemoveEventPartyMember: #{e.message}")
      return {
        event_party: nil,
        contest: nil,
        errors: ["Unable to remove party member"]
      }
    end
  end

end