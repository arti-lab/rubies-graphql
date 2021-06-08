class Types::PlaygroundType < Types::BaseObject
  field :creator, Types::UserType, null: false
  field :name, String, null: false
  field :slug, String, null: false
  field :chat_channel_name, String, null: false
  field :description, String, null: true
  field :avatar_url, String, null: true
  field :contests, [Types::ContestType], null: true
  field :invite_url, String, null: false
  field :am_i_member, Boolean, null: true
  field :contest_templates_i_host, [Types::ContestTemplateType], null: true
  field :contest_templates_i_mod, [Types::ContestTemplateType], null: true

  connection :contest_templates, Connections::PlaygroundContestTemplatesConnection, {filter: Types::Filter::ContestTemplateFilters}
  connection :members, Connections::PlaygroundMembersConnection, {filters: Types::Filter::UserFilters}

  def contests
    contests = object.contest_templates.map { |template| template.contests.not_ended.not_old.recent.first }.compact.sort_by{|ct| ct.scheduled_start_time}
  end

  def chat_channel_name
    object.twilio_chat_channel_name
  end

  def invite_url
    object.invite_url
  end

  def contest_templates_i_host
    current_user = context[:current_user]
    if current_user.nil?
      return []
    end
    current_user.hosted_contest_templates.where(playground: object)
  end

  def contest_templates_i_mod
    current_user = context[:current_user]
    if current_user.nil?
      return []
    end
    current_user.moderated_contest_templates.where(playground: object)
  end

  def am_i_member
    current_user = context[:current_user]
    if current_user.nil?
      return false
    end
    return !!object.members.include?(current_user)
  end
end
