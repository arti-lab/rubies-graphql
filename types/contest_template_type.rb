class Types::ContestTemplateType < Types::BaseObject
  field :name, String, null: false
  field :description, String, null: false
  field :game, Types::GameType, null: false
  field :is_featured, Boolean, null: false
  field :has_doors_open_contest, Boolean, null: false
  field :scheduled_start_time, Types::Filter::Common::DateTime, null: false
  field :duration_sec, Integer, null: false
  field :host, Types::UserType, null: false
  field :config, GraphQL::Types::JSON, null: true
  field :slug, String, null: false
  field :rules_md, String, null: true
  field :recurrence, String, null: true
  field :prizes_md, String, null: true
  field :splash_img_url, String, null: false
  field :prizes_desc_short_md, String, null: true
  field :format_desc_short_md, String, null: true
  field :current_contest, Types::ContestType, null: true
  field :can_edit, Boolean, null: false
  field :am_i_following, Boolean, null: false
  field :mods, [Types::UserType], null: false
  field :playground, Types::PlaygroundType, null: true
  field :invite_url, String, null: false

  connection :contests, Connections::ContestChildrenConnection, {filter: Types::Filter::ContestFilters}

  def has_doors_open_contest
    object.latest_contest_occurrence.doors_open?
  end

  def splash_img_url
    object.splash_img_url || "https://s3.us-east-2.amazonaws.com/visor-s3-production-us-east-2/manual_uploads/bloodhound_large.png"
  end

  def current_contest
    object.latest_contest_occurrence
  end

  def playground
    RecordLoader.for(Playground).load(object.playground_id) 
  end

  def mods
    ForeignKeyLoader.for(ContestTemplate, :contest_template_mods).load([object.id]).then do |contest_template_mods|
      ForeignKeyLoader.for(ContestTemplateMod, :user).load(contest_template_mods.map(&:user_id))
    end
  end

  def am_i_following
    current_user = context[:current_user]
    if current_user.nil?
      return false
    end
    cf = ContestFollow.find_by(user: current_user, contest_template: object)
    !cf.blank?
  end

  def can_edit
    current_user = context[:current_user]
    if current_user.nil?
      return false
    end
    object.can_edit?(current_user)
  end

  def invite_url
    base_url = object.playground.invite_url
    "#{base_url}?contest=#{object.slug}"
  end

end
