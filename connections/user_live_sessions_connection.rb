class Connections::UserLiveSessionsConnection < Connections::BaseConnectionType
  edge_type(Edges::LiveSessionsEdge, node_type: Types::LiveSessionType)
end
