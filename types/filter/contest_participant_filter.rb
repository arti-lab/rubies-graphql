class Types::Filter::ContestParticipantFilter < Types::Filter::BaseFilter
  description "Filter for contest participants"
  argument :score, Types::Filter::Common::NumberOperators, required: false

  TABLE_NAME = "contest_participants"

  def resolve(query)
    unless self.score.nil?
      query = self.score.resolve(query, "#{TABLE_NAME}.score")
    end
    query
  end
end

