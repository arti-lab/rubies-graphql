class Types::ContestParticipantType < Types::BaseObject
  field :score, Integer, null: true
  field :score_2, Integer, null: true
  field :user, Types::UserType, null: false
  field :placement, Integer,
    null: true,
    resolve: ->(obj, args, ctx) {
      ForeignKeyLoader.for(ContestParticipant, :contest_id).load([obj.contest_id]).then do |contest_participants|
        primary_num_better = 0
        secondary_num_better = 0
        contest_participants.each do |cp|
          if cp.score.to_i > obj.score.to_i
            primary_num_better = primary_num_better + 1
          end
        end
        contest_participants.each do |cp|
          if cp.score.to_i == obj.score.to_i && cp.score_2.to_i > obj.score_2.to_i
            secondary_num_better = secondary_num_better + 1
          end
        end
        primary_num_better + secondary_num_better + 1
      end
    }
  field :matches, [Types::MatchType],
    null: false,
    resolve: ->(obj, args, ctx) {
      ForeignKeyLoader.for(Match, :contest_participant_id).load([obj.id])
    }
  field :streak, Integer, null: false
  field :team, String, null: true
  field :party, Types::EventPartyType, null: true

  def user
    RecordLoader.for(User).load(object.participant_id)
  end

  def matches
    object.matches.order("created_at ASC")
  end

  def streak
    streak_count = 1
    begin
      contests = object.contest.contest_template&.contests&.where(has_ended: true)&.order("start_time DESC")
      return 0 if contests.nil?
      cps = ContestParticipant.where(participant: object.participant, contest: contests).order("created_at DESC")
      contests.each do |c|
        if cps.find{|cp| cp.contest_id === c.id}
          streak_count += 1
        else
          break
        end
      end
    rescue => e
      # no-op
    end

    # TODO: initialize at 1. This is for backwards compatibility.
    return streak_count == 1 ? 0 : streak_count
  end

  def party
    object.current_party
  end

end
