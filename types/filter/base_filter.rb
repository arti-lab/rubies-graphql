class Types::Filter::BaseFilter < Types::BaseInputObject
  description "Base class for filter input objects"

  TABLE_NAME = "Not Implemented"

  def resolve(query)
    raise StandardError, "Not Implemented Error"
  end
end
