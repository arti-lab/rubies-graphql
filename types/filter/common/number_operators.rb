class Types::Filter::Common::NumberOperators < Types::Filter::BaseFilter
  description "Operators for filtering on numbers"
  argument :eq, Float, required: false
  argument :lt, Float, required: false
  argument :lte, Float, required: false
  argument :gt, Float, required: false
  argument :gte, Float, required: false
  argument :between, Types::Filter::Common::NumberRange, required: false

  def resolve(query, attribute)
    unless self.eq.nil?
      query = query.send(:where, Hash[attribute, self.eq])
    end
    unless self.lt.nil?
      query = query.where("#{attribute} < ?", self.lt)
    end
    unless self.lte.nil?
      query = query.where("#{attribute} <= ?", self.lte)
    end
    unless self.gt.nil?
      query = query.where("#{attribute} > ?", self.gt)
    end
    unless self.gte.nil?
      query = query.where("#{attribute} >= ?", self.gte)
    end
    unless self.between.nil?
      query = self.between.resolve(query, attribute)
    end
    query
  end
end
