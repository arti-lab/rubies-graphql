class Mutations::UpdatePartyScoreAdjustment < Mutations::BaseMutation
  null false

  argument :contest, ID, required: true, loads: Types::ContestType
  argument :party, ID, required: true, loads: Types::EventPartyType
  argument :adjustment_value, Int, required: true

  field :contest, Types::ContestType, null: true
  field :party, Types::EventPartyType, null: true

  def resolve(contest:, party:, adjustment_value:)
    current_user = context[:current_user]

    raise "Error" if !current_user

    if !contest.contest_template.can_edit?(current_user)
      return {
          party: nil,
          errors: ["User does not have permission to end contest"],
      }
    end

    party.add_score_adjustment(adjustment_value)

    return {
        party: party,
        errors: [],
    }
  end
end
