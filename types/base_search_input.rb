class Types::BaseSearchInput < Types::BaseInputObject
  description "Shared attributes by all models"
  argument :created_at, String, required: false
  argument :updated_at, String, required: false
end