class Mutations::CreateOrUpdateMatch < Mutations::BaseMutation
  null false

  argument :contest_slug, String, required: true
  argument :username, String, required: true
  argument :score, Int, required: true
  argument :score2, Int, required: false
  argument :match_id, String, required: false


  field :match, Types::MatchType, null: true

  def resolve(
      contest_slug:,
      username:,
      match_id: nil,
      score:,
      score2: nil
  )
    current_user = context[:current_user]
    contest = Contest.find_by(slug: contest_slug)
    contest_template = contest.contest_template
    if !current_user || !contest_template.can_edit?(current_user)
      return {
          match: nil,
          errors: ["Access denied"]
      }
    end

    if contest.blank?
      return {
          match: nil,
          errors: ["Could not find a contest by that slug"]
      }
    end
    participant = User.find_by(username: username)
    if participant.blank?
      return {
          match: nil,
          errors: ["Could not find a user by that username"]
      }
    end
    cp = participant.contest_participants.where(contest: contest).first
    if cp.blank?
      return {
          match: nil,
          errors: ["User not participating in this contest"]
      }
    end

    uuid = match_id || "admin-#{rand(36**20).to_s(36)}"
    begin
      match = Match.find_by(uuid: uuid)
      if match.blank?
        last_match = cp.matches.last
        if !last_match.blank? && last_match.uuid.include?("admin")
          match = last_match
          match.score = match.score.to_i + score
          match.score_2 = match.score_2.to_i + score2
        else
          match = cp.matches.new(uuid: uuid, score: score, score_2: score2)
        end
        if match.save
          cp.refresh_score!
          return {
              match: match,
              errors: []
          }
        else
          return {
              match: nil,
              errors: match.errors.full_messages
          }
        end
      else
        if match.update(score: score || match.score, score_2: score2 || match.score2)
          cp.refresh_score!
          return {
              match: match,
              errors: []
          }
        else
          return {
              match: nil,
              errors: match.errors.full_messages
          }
        end
      end

    rescue => exception
      return {
          match: nil,
          errors: ["Unable to create match"]
      }
    end

  end

end
