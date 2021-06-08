class Types::Filter::UserFilters < Types::Filter::BaseFilter
  description "Filters for users"
  argument :id, Types::Filter::Common::StringOperators, required: false
  argument :email, Types::Filter::Common::StringOperators, required: false
  argument :username, Types::Filter::Common::StringOperators, required: false
  argument :slug, Types::Filter::Common::StringOperators, required: false

  TABLE_NAME = "users"

  def resolve(query)
    unless self.id.nil?
      query = self.id.resolve(query, "#{TABLE_NAME}.id")
    end
    unless self.email.nil?
      query = self.email.resolve(query, "#{TABLE_NAME}.email")
    end
    unless self.username.nil?
      query = self.username.resolve(query, "#{TABLE_NAME}.username")
    end
    unless self.slug.nil?
      query = self.slug.resolve(query, "#{TABLE_NAME}.slug")
    end
    query
  end
end
