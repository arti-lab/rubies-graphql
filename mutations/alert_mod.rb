class Mutations::AlertMod < Mutations::BaseMutation
  argument :mod_discord_name, String, required: true
  argument :user_discord_name, String, required: false
  argument :message, String, required: false

  field :success, Boolean, null: false

  def resolve(mod_discord_name:, user_discord_name: nil, message: "")
    current_user = context[:current_user]
    if current_user.blank?
      return {
        success: false,
        errors: ["Access denied"]
      }
    end
    begin
      if !user_discord_name.blank? && user_discord_name != current_user.discord_name
        current_user.update(discord_name: user_discord_name)
      end
      DiscordBot.alert_mod(
        mod_discord_name: mod_discord_name,
        user_discord_name: current_user.discord_name,
        message: message,
      )
    rescue => e
      return {
        success: false,
        errors: ["Unable to send message to mod"]
      }
    end
    return {
      success: true,
      errors: []
    }
  end
end