class Connections::ContestEventPartiesConnection < Connections::BaseConnectionType
  edge_type(Edges::EventPartiesEdge, node_type: Types::EventPartyType)

  ATTRIBUTE_WHITELIST = [:placement_score, :created_at, :updated_at]
end

