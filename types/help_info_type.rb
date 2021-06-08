class Types::HelpInfoType < Types::BaseObject
  field :topic, String, null: false
  field :subtopic, String, null: false
  field :content, String, null: false
  field :image_url, String, null: true
end
