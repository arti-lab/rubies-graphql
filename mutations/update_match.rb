class Mutations::UpdateMatch < Mutations::BaseMutation
  null false

  argument :message, String, required: true
  argument :game_slug, String, required: false # Backwards compatibility. Remove after July
  field :should_alert, Boolean, null: false

  def resolve(message:, game_slug: nil)
    current_user = context[:current_user]
    score_changed = false
    errors = []
    begin
      if game_slug === "fortnite"
        score_changed = Match.create_from_fortnite_message!(current_user, message)
      else
        score_changed = Match.create_from_apex_message!(current_user, message)
      end
    rescue ClientMessageDecryptor::DecryptError => e
      Rails.logger.fatal("UpdateMatch: Invalid message from User #{current_user.slug}: #{message}")
      errors = ["Error saving message"]
    rescue => e
      Rails.logger.fatal("UpdateMatch: from User #{current_user ? current_user.slug: "0"}: #{e.message}")
      errors = [e.message]
    end

    return {
      should_alert: score_changed,
      errors: errors
    }
  end

end
