class Types::ProfileUpdateRequestType < Types::BaseObject
  field :requestor, Types::UserType, null: false
  field :requestee, Types::UserType, null: false
  field :field, String, null: false
  field :value, String, null: false
  field :resolution, String, null: false

end

