class Mutations::UpdateUserSettings < Mutations::BaseMutation
  null false

  argument :overwatch_rank, String, required: false
  argument :paypal_email, String, required: false
  argument :venmo_account, String, required: false
  argument :username, String, required: false
  argument :description, String, required: false
  argument :email, String, required: false
  argument :old_password, String, required: false
  argument :new_password, String, required: false
  argument :discord_name, String, required: false
  argument :social_mixer, String, required: false
  argument :social_twitter, String, required: false
  argument :social_discord, String, required: false
  argument :social_twitch, String, required: false
  argument :social_youtube, String, required: false
  argument :stream_login, String, required: false
  argument :stream_platform, String, required: false
  argument :social_privacy_discord, String, required: false
  argument :social_privacy_mixer, String, required: false
  argument :social_privacy_twitter, String, required: false
  argument :social_privacy_twitch, String, required: false
  argument :social_privacy_youtube, String, required: false
  argument :beacon_privacy, Types::User::UserBeaconPrivacy, required: false

  field :user, Types::UserType, null: true

  def resolve(
    overwatch_rank: nil,
    paypal_email: nil,
    venmo_account: nil,
    username: nil,
    description: nil,
    email: nil,
    old_password: nil,
    new_password: nil,
    discord_name: nil,
    beacon_privacy: nil,
    social_mixer: nil,
    social_twitter: nil,
    social_discord: nil,
    social_twitch: nil,
    social_youtube: nil,
    stream_login: nil,
    stream_platform: nil,
    social_privacy_discord: nil,
    social_privacy_mixer: nil,
    social_privacy_twitter: nil,
    social_privacy_twitch: nil,
    social_privacy_youtube: nil
  )
    current_user = context[:current_user]

    if old_password
      if !current_user.valid_password?(old_password)
        return {
          user: nil,
          errors: ["Incorrect current password"]
        }
      end
      if current_user.update(password: new_password)
        return {
          user: current_user,
          errors: [],
        }
      else
        return {
          user: nil,
          errors: current_user.errors.full_messages
        }
      end
    end

    new_fields = {
      beacon_privacy: beacon_privacy,
      description: description,
      email: email,
      overwatch_rank: overwatch_rank,
      paypal_email: paypal_email,
      venmo_account: venmo_account,
      username: username,
      discord_name: discord_name,
      beacon_privacy: beacon_privacy,
      social_mixer: social_mixer,
      social_twitter: social_twitter,
      social_discord: social_discord,
      social_twitch: social_twitch,
      social_youtube: social_youtube,
      stream_login: stream_login,
      stream_platform: stream_platform,
      social_privacy_discord: social_privacy_discord,
      social_privacy_mixer: social_privacy_mixer,
      social_privacy_twitter: social_privacy_twitter,
      social_privacy_twitch: social_privacy_twitch,
      social_privacy_youtube: social_privacy_youtube,
    }.compact

    if current_user.update(new_fields)
      return {
        user: current_user,
        errors: [],
      }
    else
      return {
        user: nil,
        errors: current_user.errors.full_messages
      }
    end
  end

end
