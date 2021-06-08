class Connections::PlaygroundContestTemplatesConnection < Connections::BaseConnectionType
  edge_type(Edges::ContestTemplatesEdge, node_type: Types::ContestTemplateType)
end
