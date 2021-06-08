class Connections::UserContestBadgesConnection < Connections::BaseConnectionType
  edge_type(Edges::BadgesEdge, node_type: Types::BadgeType )
end