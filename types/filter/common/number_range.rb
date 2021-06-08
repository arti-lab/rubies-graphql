class Types::Filter::Common::NumberRange < Types::Filter::BaseFilter
  description "Bounds for a range of numbers"
  argument :start, Float, required: true
  argument :end, Float, required: true

  def resolve(query, attribute)
    unless self.start.nil? || self.end.nil?
      query = query.where("#{attribute} >= ?", self.start).where("#{attribute} < ?", self.end)
    end
    query
  end
end
