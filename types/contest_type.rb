class Types::ContestType < Types::BaseObject
  field :name, String, null: false
  field :description, String, null: false
  field :game, Types::GameType, null: false
  field :start_time, Types::Filter::Common::DateTime, null: true
  field :scheduled_start_time, Types::Filter::Common::DateTime, null: false
  field :duration_sec, Integer, null: false
  field :end_time, Types::Filter::Common::DateTime, null: true
  field :scheduled_end_time, Types::Filter::Common::DateTime, null: false
  field :doors_open_time, Types::Filter::Common::DateTime, null: false
  field :doors_open, Boolean, null: false
  field :host, Types::UserType, null: false
  field :config, GraphQL::Types::JSON, null: true
  field :slug, String, null: false
  field :is_active, Boolean, null: false
  field :has_ended, Boolean, null: false
  field :rules_md, String, null: true
  field :prizes_md, String, null: true
  field :splash_img_url, String, null: false
  field :prizes_desc_short_md, String, null: true
  field :format_desc_short_md, String, null: true
  field :leaderboard_titles, [String], null: false
  field :score_types, [String], null: false
  field :team_names, [String], null: false
  field :game_mode, String, null: false
  field :contest_template, Types::ContestTemplateType, null: false
  field :chat_channel_name, String, null: false
  field :party_size_limit, Integer, null: true

  field :host_entry, Types::ContestParticipantType, null: true
  field :my_entry, Types::ContestParticipantType, null: true
  field :my_party, Types::EventPartyType, null: true

  field :my_hundred_thieves_attempts, GraphQL::Types::JSON, null: true

  field :participants, Connections::ContestContestParticipantsConnection,
    null: false,
    resolve: ->(obj, args, ctx) {
      ForeignKeyLoader.for(ContestParticipant, :contest_id).load([obj.id]).then do |contest_participants|
        input = args[:sortBy]
        unless input.nil?
          cleaned_args = []
          input.split(' ').each do |field|
            field_parts = field.rpartition('_')
            name = field_parts.first.underscore
            direction = field_parts.last
            if direction == "DESC"
              direction = -1
            else
              direction = 1
            end
            # [1, "score"]
            cleaned_args.push([direction, name])
          end
        end
        contest_participants = contest_participants.sort_by{|cp| cleaned_args.map{|arg| arg[0] * cp.send(arg[1]).to_i}}
      end
    } do
      argument :sort_by, String, required: false
    end

  connection :parties, Connections::ContestEventPartiesConnection,
    {
      base_resolve: ->(obj, args, ctx) {
        ids = obj.event_parties.has_members.keys
        obj.event_parties.where(id: ids)
      }
    }

  def leaderboard_titles
    return object.score_titles
  end

  def contest_template
    RecordLoader.for(ContestTemplate).load(object.contest_template_id)
  end

  def game
    RecordLoader.for(Game).load(object.game_id)
  end

  def score_types
    return object.score_keys.flatten
  end

  def team_names
    object.team_names
  end

  def game_mode
    object.game_mode
  end

  def host
    # object.host
    RecordLoader.for(User).load(object.host_id)
  end

  def end_time
    object.end_time
  end

  def doors_open
    object.doors_open?
  end

  def splash_img_url
    object.splash_img_url || "https://s3.us-east-2.amazonaws.com/visor-s3-production-us-east-2/manual_uploads/bloodhound_large.png"
  end

  def chat_channel_name
    object.twilio_chat_channel_name
  end

  def party_size_limit
    object.party_size_limit
  end

  def my_entry
    return @current_cp if defined? @current_cp
    @current_cp = ContestParticipant.where(
      participant: context[:current_user],
      contest: object
    ).first
  end

  def my_hundred_thieves_attempts
    return {} if !object.score_keys.flatten.include?("time")

    unless defined? @current_cp
      @current_cp = ContestParticipant.where(
          participant: context[:current_user],
          contest: object
      ).first
    end


    if @current_cp
      if (@current_cp.matches.blank?)
        return {}
      end

      # PLACEHOLDER CONSTANTS
      min_duration = 120000
      start_type = 10
      end_type = 31
      valid_boundary_types = [start_type, end_type]
      valid_death_types = valid_boundary_types + [16, 48]


      attempts = []
      user_id = @current_cp.matches.last.raw_result["userID"]
      start_time_to_matches = {}
      @current_cp.matches.where.not("uuid like ?", "%-D-%").each do |m|
        next if m.raw_result.blank?
        start_time = m.raw_result["start_time"]
        if start_time_to_matches[start_time].nil?
          start_time_to_matches[start_time] = [m]
        else
          start_time_to_matches[start_time] += [m]
        end
      end
      start_time_to_killfeeds = {}
      start_time_to_matches.each do |k, v|
        if v.count > 1
          extended_killfeed = []

          prev_match = nil
          total_offset_sec = 0

          v.sort_by{ |m| m.created_at }.each do |m|
            # Get split match duration
            unless prev_match.nil?
              match_duration_sec = m.created_at.to_i - prev_match.created_at.to_i
              total_offset_sec += match_duration_sec
            end

            # Add split match offset to killfeed entries
            kf = m.raw_result["killfeed"]
            kf.each do |kf_entry|
              kf_entry["timeMs"] += (total_offset_sec * 1000)
            end

            extended_killfeed += kf
            prev_match = m
          end
          start_time_to_killfeeds[k] = extended_killfeed
        else
          start_time_to_killfeeds[k] = v.first.raw_result["killfeed"]
        end
      end


      start_time_to_killfeeds.keys.sort.each do |st|
        kf = start_time_to_killfeeds[st]

        start_ms = nil
        version = 1
        kf.each do |kf_entry|
          # Invalidate search if non-suicide
          is_victim = kf_entry["killed"] == user_id
          is_killer = kf_entry["killer"] == user_id
          # Invalidate search if knock
          is_knock = !!kf_entry["knocked"]
          # Invalidate search if kill type not valid
          is_valid_death_type = valid_death_types.include?(kf_entry["type"])

          # No knocks and only valid death types allowed
          if is_knock or !is_valid_death_type
            start_ms = nil
            next
          end

          # Account for other players in lobby
          if !is_victim or !is_killer
            next
          end

          death_type = kf_entry["type"]
          # Disregard death types for boundary search
          next unless valid_boundary_types.include?(death_type)
          # Search for start and ends
          if death_type == start_type
            # Set start time
            if kf_entry["systemTimeMs"]
              version = 2
              start_ms = kf_entry["systemTimeMs"]
            else
              version = 1
              start_ms = kf_entry["timeMs"]
            end
          elsif death_type == end_type
            # Try to set end time
            # Requires a start time
            next if start_ms.nil?
            if version == 2
              duration_ms = kf_entry["systemTimeMs"] - start_ms
              started_at = start_ms
            else
              duration_ms = kf_entry["timeMs"] - start_ms
              started_at = st * 1000 + start_ms
            end
            # Must be longer than minimum duration
            next if duration_ms < min_duration
            # Add duration to list
            attempt = {
                "duration"=>duration_ms,
                "started_at"=>started_at,
            }
            attempts.append(attempt)
            # Reset search state
            start_ms = nil
          end
        end
      end

      recent_attempts = attempts.sort_by{|item| -item["started_at"]}.first(5)
      return {
        attempts: recent_attempts,
        best: attempts.sort_by{|item| item["duration"]}.first,
      }
    end

  end

  def host_entry
    return @host_cp if defined? @host_cp
    @host_cp = ContestParticipant.where(
      participant: object.host,
      contest: object
    ).first
  end

  def my_party
    unless defined? @current_cp
      @current_cp = ContestParticipant.where(
          participant: context[:current_user],
          contest: object
      ).first
    end
    return nil if @current_cp.nil?
    @current_cp.current_party
  end
end
