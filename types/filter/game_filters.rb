class Types::Filter::GameFilters < Types::Filter::BaseFilter
  description "Filters for games"
  argument :name, Types::Filter::Common::StringOperators, required: false
  argument :slug, Types::Filter::Common::StringOperators, required: false

  TABLE_NAME = "games"

  def resolve(query)
    unless self.name.nil?
      query = self.name.resolve(query, "#{TABLE_NAME}.name")
    end
    unless self.slug.nil?
      query = self.slug.resolve(query, "#{TABLE_NAME}.slug")
    end
    query
  end
end
