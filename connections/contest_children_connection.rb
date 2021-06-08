class Connections::ContestChildrenConnection < Connections::BaseConnectionType
  edge_type(Edges::ContestsEdge, node_type: Types::ContestType)
end
