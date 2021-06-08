class Types::EventPartyType < Types::BaseObject
  field :leader, Types::ContestParticipantType, null: false
  field :score, Integer, null: true
  field :am_i_leader, Boolean, null: false
  field :placement, Integer, null: true

  connection :members, Connections::EventPartyContestParticipantsConnection, {filter: Types::Filter::ContestParticipantFilter}

  def score
    object.score
  end
  
  def am_i_leader
    current_user = context[:current_user]
    if current_user.nil?
      return false
    end
    contest_participant = ContestParticipant.find_by(contest: object.contest, participant: current_user)
    object.leader == contest_participant
  end

end