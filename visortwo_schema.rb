class VisortwoSchema < GraphQL::Schema
  use(GraphQL::Tracing::NewRelicTracing)

  max_complexity 400
  default_max_page_size 200
  query Types::QueryType
  mutation Types::MutationType
  use GraphQL::Batch

  rescue_from(ActiveRecord::RecordNotFound) { "Not found" }

  def self.resolve_type(type, obj, ctx)
    case obj
    when User
      Types::UserType
    when LiveSession
      Types::LiveSession
    when Attendance
      Types::Attendance
    when Contest
      Types::ContestType
    when ContestTemplate
      Types::ContestTemplateType
    when ContestParticipant
      Types::ContestParticipantType
    when EventParty
      Types::EventPartyType
    when Playground
      Types::PlaygroundType
    when HelpInfo
      Types::HelpInfoType
    when Game
      Types::GameType
    when ProfileUpdateRequest
      Types::ProfileUpdateRequestType
    else
      raise("Unexpected object: #{obj}")
    end
  end

  def self.id_from_object(object, type_definition, query_ctx)
    object.to_gid.to_s.gsub("/", "_")
    # Rails.env.development? ? object.to_gid.to_s.gsub("/", "_") : object.to_sgid.to_s
  end

  def self.object_from_id(id, query_ctx)
    GlobalID::Locator.locate(id.gsub("_", "/"))
    # Rails.env.development? ? GlobalID::Locator.locate(id.gsub("_", "/")) : GlobalID::Locator.locate_signed(id)
  end

  private
  def self.generate_uuid(length=20)
    rand(36**length).to_s(36)
  end

end
