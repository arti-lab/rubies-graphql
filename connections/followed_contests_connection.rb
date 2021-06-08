class Connections::FollowedContestsConnection < Connections::BaseConnectionType
  edge_type(Edges::ContestTemplatesEdge, node_type: Types::ContestTemplateType)
end
