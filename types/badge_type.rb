class Types::BadgeType < Types::BaseObject
  field :contest_template, Types::ContestTemplateType, null: false
  field :name, String, null: false
  field :url, String, null: false
end
