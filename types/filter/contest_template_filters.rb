class Types::Filter::ContestTemplateFilters < Types::Filter::BaseFilter
  description "Filters for contest templates"
  argument :id, Types::Filter::Common::StringOperators, required: false
  argument :name, Types::Filter::Common::StringOperators, required: false
  argument :host_id, Types::Filter::Common::NumberOperators, required: false
  argument :game_id, Types::Filter::Common::NumberOperators, required: false
  argument :slug, Types::Filter::Common::StringOperators, required: false
  argument :scheduled_start_time, Types::Filter::Common::DateOperators, required: false
  argument :duration_sec, Types::Filter::Common::NumberOperators, required: false
  argument :is_featured, Types::Filter::Common::BooleanOperators, required: false

  TABLE_NAME = "contest_templates"

  def resolve(query)
    unless self.id.nil?
      query = self.id.resolve(query, "#{TABLE_NAME}.id")
    end
    unless self.name.nil?
      query = self.name.resolve(query, "#{TABLE_NAME}.name")
    end
    unless self.host_id.nil?
      query = self.host_id.resolve(query, "#{TABLE_NAME}.host_id")
    end
    unless self.game_id.nil?
      query = self.game_id.resolve(query, "#{TABLE_NAME}.game_id")
    end
    unless self.slug.nil?
      query = self.slug.resolve(query, "#{TABLE_NAME}.slug")
    end
    unless self.scheduled_start_time.nil?
      query = self.scheduled_start_time.resolve(query, "#{TABLE_NAME}.scheduled_start_time")
    end
    unless self.duration_sec.nil?
      query = self.duration_sec.resolve(query, "#{TABLE_NAME}.duration_sec")
    end
    unless self.is_featured.nil?
      query = self.is_featured.resolve(query, "#{TABLE_NAME}.is_featured")
    end
    query
  end
end
