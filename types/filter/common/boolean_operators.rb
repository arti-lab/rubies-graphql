class Types::Filter::Common::BooleanOperators < Types::Filter::BaseFilter
  description "Operators for filtering on booleans"
  argument :eq, Boolean, required: false

  def resolve(query, attribute)
    unless self.eq.nil?
      query = query.send(:where, Hash[attribute, self.eq])
    end
    query
  end
end
