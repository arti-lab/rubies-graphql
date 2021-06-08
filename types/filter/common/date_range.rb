class Types::Filter::Common::DateRange < Types::Filter::BaseFilter
  description "Bounds for a range of dates"
  argument :start, Types::Filter::Common::DateTime, required: true
  argument :end, Types::Filter::Common::DateTime, required: true

  def resolve(query, attribute)
    unless self.start.nil? || self.end.nil?
      query = query.where("#{attribute} >= ?", self.start).where("#{attribute} < ?", self.end)
    end
    query
  end
end
