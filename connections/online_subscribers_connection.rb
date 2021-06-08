class Connections::OnlineSubscribersConnection < Connections::BaseConnectionType
  edge_type(Edges::UsersEdge, node_type: Types::UserType)
end
