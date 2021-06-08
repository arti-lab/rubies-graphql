class Types::UserType < Types::BaseObject
  field :email, String, null: false
  field :username, String, null: false
  field :slug, String, null: false
  field :description, String, null: true
  field :avatar_url, String, null: true
  field :overwatch_rank, String, null: true
  field :beacon_game, String, null: true
  field :beacon_game_name, String, null: true
  field :beacon_message, String, null: true
  field :stream_key, String, null: true
  field :beacon_status, Types::User::UserBeaconStatus, null: true
  field :beacon_privacy, Types::User::UserBeaconPrivacy, null: false
  field :updated_at, Types::Filter::Common::DateTime, null: false
  field :notification_setting, Types::NotificationSettingType, null: true
  field :rtmp_url, String, null: true
  field :paypal_email, String, null: true
  field :venmo_account, String, null: true
  field :social_link, String, null: true
  field :social_mixer, String, null: true
  field :social_twitter, String, null: true
  field :social_discord, String, null: true
  field :social_twitch, String, null: true
  field :social_youtube, String, null: true
  field :stream_login, String, null: true
  field :stream_platform, Types::Filter::User::StreamPlatform, null: true
  field :discord_name, String, null: true
  field :social_privacy_discord, String, null: true
  field :social_privacy_mixer, String, null: true
  field :social_privacy_twitter, String, null: true
  field :social_privacy_twitch, String, null: true
  field :social_privacy_youtube, String, null: true
  field :badges, [Types::BadgeType], null: false

  field :active_live_session, Types::LiveSessionType, null: true
  field :is_visor_admin, Boolean, null: false
  field :is_verified_host, Boolean, null: true
  field :am_i_following, Boolean, null: true, resolve: ->(obj, args, ctx) {
    if ctx[:current_user]
      ctx[:current_user].following?(obj)
    end
  } do; end
  field :is_claimed, Boolean, null: false, resolve: ->(obj, args, ctx) {
    obj.is_claimed
  }
  field :my_contests, [Types::ContestTemplateType], null: true
  field :my_moderated_contests, [Types::ContestTemplateType], null: true

  field :joined_playgrounds, [Types::PlaygroundType], null: true
  field :created_playgrounds, [Types::PlaygroundType], null: true

  # Pending requests to update user's profile
  field :pending_requested_profile_updates, [Types::ProfileUpdateRequestType], null: true

  connection :followers, Connections::UserFollowersConnection, {filter: Types::Filter::UserFilters}
  connection :following, Connections::UserFollowingsConnection, {filter: Types::Filter::UserFilters}

  # Followed contest templates
  connection :followed_contests, Connections::FollowedContestsConnection, {filter: Types::Filter::ContestTemplateFilters}

  connection :live_sessions, Connections::UserLiveSessionsConnection,
    base_resolve: ->(obj, args, ctx) {
      user = obj
      user_hosted_sessions = user.live_sessions
      user_attended_sessions = LiveSession.with_attendee(user.id)
      sessions = []
      user_hosted_sessions.each do |session|
        unless user_attended_sessions.include?(session)
          sessions << session
        end
      end

      user_attended_sessions.each do |session|
        sessions << session
      end

      sessions.sort { |s| s.end_time.to_i }
    }

  connection :sponsors, Connections::UserSponsorsConnection

  connection :badges, Connections::UserContestBadgesConnection, {filter: Types::Filter::BadgeFilters}

  def get_record_id(object)
    object.friendly_id
  end

  def beacon_game_name
    object.beacon_game
  end

  def my_contests
    object.contest_templates
  end

  def my_moderated_contests
    object.moderated_contest_templates
  end

  def pending_requested_profile_updates
    object.requested_profile_updates.pending
  end

  def stream_key
    "#{object.slug}@#{object.stream_key}"
  end

  private
end
