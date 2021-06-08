class Types::QueryType < Types::BaseObject
  field :node, field: GraphQL::Relay::Node.field
  field :nodes, field: GraphQL::Relay::Node.plural_field

  field :user, Types::UserType, 'Query user by slug',
    null: true,
    resolve: ->(obj, args, ctx) {
      User.friendly.find(args[:slug])
    } do
      argument :slug, String, required: true
    end

  field :me, Types::UserType, 'Query me',
    null: true,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      ctx[:current_user]
    } do; end

  field :admin, Types::AdminType, 'admin-specific queries',
    null: true,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      user = ctx[:current_user]
      if !user.is_visor_admin
        raise GraphQL::ExecutionError.new("Insufficient Permission")
      end
      user.id = -1 # Special admin type
      user
    } do; end

  field :featured_contests, [Types::ContestType], 'Query contest by slug',
    null: false,
    resolve: ->(obj, args, ctx) {
      user = ctx[:current_user]
      templates = ContestTemplate.featured
      if user
        templates =  templates + ContestTemplate.is_followed_by(user).featured
        templates.uniq!
      end
      templates.map { |template| template.contests.not_ended.recent.first }.compact.sort_by{|ct| ct.scheduled_start_time}
    } do; end

  field :contest, Types::ContestType, 'Query contest by slug',
    null: true,
    resolve: ->(obj, args, ctx) {
      Contest.friendly.find(args[:slug])
    } do
      argument :slug, String, required: true
    end

  field :contest_template, Types::ContestTemplateType, 'Query contest template by slug',
    null: true,
    resolve: ->(obj, args, ctx) {
      ContestTemplate.friendly.find(args[:slug])
    } do
      argument :slug, String, required: true
    end

  field :contest_templates, [Types::ContestTemplateType], 'All contest templates',
    null: true,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      user = ctx[:current_user]
      if !user.is_visor_admin
        raise "Insufficient permissions"
      end
      ContestTemplate.all.order(:name)
    } do; end

  field :playground, Types::PlaygroundType, 'Query playground by slug',
    null: true,
    resolve: ->(obj, args, ctx) {
      Playground.find_by(slug: args[:slug])
    } do
    argument :slug, String, required: true
  end

  field :help_topics, [Types::HelpInfoType], 'Get Help Topics',
    null: false,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      topics = HelpInfo.select(:topic).distinct.map{|hi| hi.topic}
      first_rows = HelpInfo.where(topic: topics).group_by(&:topic).map{|k, v| v.first.id}
      HelpInfo.where(id: first_rows).order(:id)
    } do; end

  field :help_subtopics, [Types::HelpInfoType], 'Get help subtopics and content',
    null: false,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      HelpInfo.where(topic: args[:topic])
    } do
      argument :topic, String, required: true
    end

  field :verified_hosts, [Types::UserType], 'Get all verified hosts',
    null: false,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      User.where(is_verified_host: true)
    } do; end

  field :flash_prize_winner, [GraphQL::Types::JSON], 'Get flash prize winner',
    null: false,
    resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      c = Contest.friendly.find(args[:contestSlug])
      username = nil
      category = args[:category]
      criteria = args[:criteria]
      duration = args[:duration]
      if (
        category == "most_kills" &&
        (ApexConstants::Legends::LEGENDS.include?(criteria) || criteria == "any") &&
        duration == "single_game"
      )
        results = c.most_kills_in_single_match_with_legend(legend: criteria)
      elsif (
        category == "most_kills" &&
        (ApexConstants::Legends::LEGENDS.include?(criteria) || criteria == "any") &&
        duration == "total"
      )
        results = c.most_total_kills_with_legend(legend: criteria)
      elsif (
        category == "most_kills" &&
        (ApexConstants::Weapons::WEAPONS.include?(criteria) || criteria == "any") &&
        duration == "single_game"
      )
        results = c.most_kills_in_single_match_with_weapon(weapon: criteria)
      elsif (
        category == "most_kills" &&
        (ApexConstants::Weapons::WEAPONS.include?(criteria) || criteria == "any") &&
        duration == "total"
      )
        results = c.most_total_kills_with_weapon(weapon: criteria)
      elsif (
        category == "most_matches" &&
        (ApexConstants::Legends::LEGENDS.include?(criteria) || criteria == "any")
      )
        results = c.most_matches_played_as_legend(legend: criteria)
      elsif category == "most_matches" && criteria == "without_weapon"
        results = c.most_matches_without_weapon
      elsif category == "shortest_match"
        results = c.shortest_match_ending_with_weapon(weapon: criteria)
      else
        raise "Invalid flash prize criteria combination"
      end
      if results.blank? || results[0][:username].nil?
        return [{
          error: "Couldn't find a flash prize winner"
        }]
      end
      results
    } do
      argument :contest_slug, String , required: true
      argument :category, String, required: true
      argument :criteria, String, required: false
      argument :duration, String, required: false
    end

  connection :online_subscribers, Connections::OnlineSubscribersConnection,
    base_resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      ctx[:current_user].followers.online
    } do; end

  connection :online_users, Connections::OnlineUsersConnection,
    base_resolve: ->(obj, args, ctx) {
      require_logged_in(ctx)
      followers = ctx[:current_user].followers.online
      User.online.public_privacy.where.not(id: followers).limit(100)
    } do; end

  private

  def self.require_logged_in(ctx)
    raise GraphQL::ExecutionError.new("You are not logged in") unless ctx[:current_user]
  end
end
