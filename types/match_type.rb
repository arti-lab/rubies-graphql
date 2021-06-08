class Types::MatchType < Types::BaseObject
  field :uuid, String, null: true
  field :score, Integer, null: true
  field :score_2, Integer, null: true
  field :contest_participant, Types::ContestParticipantType, null: false
end
