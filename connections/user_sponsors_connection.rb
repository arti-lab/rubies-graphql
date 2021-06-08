class Connections::UserSponsorsConnection < Connections::BaseConnectionType
  edge_type(Edges::SponsorsEdge, node_type: Types::SponsorType)
end
