class Connections::UserFollowingsConnection < Connections::BaseConnectionType
  edge_type(Edges::UsersEdge, node_type: Types::UserType)
end
