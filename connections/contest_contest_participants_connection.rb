class Connections::ContestContestParticipantsConnection < Connections::BaseConnectionType
  edge_type(Edges::ContestParticipantsEdge, node_type: Types::ContestParticipantType)

  ATTRIBUTE_WHITELIST = [:score, :created_at, :updated_at, :score_2]
end
