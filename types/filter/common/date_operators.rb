class Types::Filter::Common::DateOperators < Types::Filter::BaseFilter
  description "Operators for filtering on dates"
  argument :eq, Types::Filter::Common::DateTime, required: false
  argument :before, Types::Filter::Common::DateTime, required: false
  argument :after, Types::Filter::Common::DateTime, required: false
  argument :between, Types::Filter::Common::DateRange, required: false

  def resolve(query, attribute)
    unless self.eq.nil?
      query = query.send(:where, Hash[attribute, self.eq])
    end
    unless self.before.nil?
      query = query.where("#{attribute} < ?", self.before)
    end
    unless self.after.nil?
      query = query.where("#{attribute} >= ?", self.after)
    end
    unless self.between.nil?
      query = self.between.resolve(query, attribute)
    end
    query
  end
end
