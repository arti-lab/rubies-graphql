class Types::Filter::BadgeFilters < Types::Filter::BaseFilter
  description "Filters for badges"
  argument :contest_template_slug, String, required: false

  def resolve(query)
    unless self.contest_template_slug.nil?
      query = query.where(
        contest_template: ContestTemplate.friendly.find(self.contest_template_slug)
      )
    end
    query.limit(3)
  end
end

