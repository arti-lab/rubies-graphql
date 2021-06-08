class Edges::UsersEdge < GraphQL::Types::Relay::BaseEdge
  node_type(Types::UserType)
end
