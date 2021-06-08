class Types::SponsorType < Types::BaseObject
  field :name, String, null: false
  field :url, String, null: true
  field :logo_url, String, null: true
end
