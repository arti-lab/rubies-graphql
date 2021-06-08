class Connections::BaseConnectionType < GraphQL::Types::Relay::BaseConnection

  # graphql search terms are used in camelCase and map to snake_case sql fields
  ATTRIBUTE_WHITELIST = [:created_at, :updated_at]
  # any direction item can be used with any search term for sortBy
  # e.g. sortBy whitelist: createdAt_ASC createdAt_DESC updatedAt_ASC updatedAt_DESC
  DIRECTION_WHITELIST = [:ASC, :DESC]

  field :total_count, Integer, null: false
  def total_count
    object.nodes.size
  end
end
