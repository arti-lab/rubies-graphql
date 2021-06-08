class Types::Filter::Common::StringOperators < Types::Filter::BaseFilter
  description "Operators for filtering on strings"
  argument :eq, String, required: false
  argument :contains, String, required: false

  def resolve(query, attribute)
    unless self.eq.nil?
      query = query.send(:where, Hash[attribute, self.eq])
    end
    unless self.contains.nil?
      query = query.where("#{attribute} like ?", "%#{self.contains}%")
    end
    query
  end
end
