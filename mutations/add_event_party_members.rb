class Mutations::AddEventPartyMembers < Mutations::BaseMutation
  null false
  argument :user_slugs, [String], required: true
  argument :event_party, ID, required: true, loads: Types::EventPartyType

  field :event_party, Types::EventPartyType, null: true
  def resolve(user_slugs:, event_party:)
    current_user = context[:current_user]
    raise "Error" if !current_user
    raise "Invalid permissions" if event_party.leader.participant != current_user
    current_party_size = event_party.current_memberships.count
    party_size_limit = event_party.contest.party_size_limit

    if (
      !party_size_limit.nil? &&
      current_party_size + user_slugs.count > party_size_limit
    )
      return {
        event_party: nil,
        errors: ["The current event has a party size limit of #{party_size_limit}"],
      }
    end

    ActiveRecord::Base.transaction do
      user_slugs.each do |s|
        begin
          user = User.friendly.find(s)
          contest = event_party.contest

          contest_participant = ContestParticipant.find_by(participant: user, contest: contest)
          if contest_participant.blank?
            return {
              event_party: nil,
              errors: ["Couldn't find contest participant"]
            }
          end
          if !contest_participant.current_party.blank?
            return {
              event_party: nil,
              errors: ["The user is already in a party"]
            }
          end
          if contest.party_size_limit.nil? or event_party.party_size < contest.party_size_limit
            event_party.add_member(contest_participant)
          else
            return {
                event_party: nil,
                errors: ["Party is full"]
            }
          end
        rescue => e
          Rails.logger.fatal("Mutations::AddEventPartyMember: #{e.message}")
          return {
            event_party: nil,
            errors: ["Unable to add party members"]
          }
        end
      end
      return {
        event_party: event_party,
        errors: [],
      }
    end
  end

end
