class Mutations::ResolveProfileUpdateRequest < Mutations::BaseMutation
  null false

  argument :profile_update_request, ID, required: true, loads: Types::ProfileUpdateRequestType
  argument :resolution, String, required: true

  field :user, Types::UserType, null: true
  field :profile_update_request, Types::ProfileUpdateRequestType, null: true

  def resolve(profile_update_request:, resolution:)
    current_user = context[:current_user]
    raise "Error" if !current_user

    raise "Incorrect user resolving request" if current_user != profile_update_request.requestee

    begin
      if resolution == ProfileUpdateRequest::ACCEPTED
        if profile_update_request.field == "stream_info"
          parts = profile_update_request.value.split("|")
          fields = {
            stream_platform: parts[0],
            stream_login: parts[1],
          }
          if current_user.update(fields) && profile_update_request.update(resolution: resolution)
            return {
              user: current_user,
              profile_update_request: profile_update_request,
              errors: [],
            }
          end
        else
          if (current_user.update("#{profile_update_request.field}": profile_update_request.value) &&
            profile_update_request.update(resolution: resolution))

            return {
              user: current_user,
              profile_update_request: profile_update_request,
              errors: [],
            }
          end
        end
      elsif resolution == ProfileUpdateRequest::REJECTED
        if profile_update_request.update(resolution: resolution)
          return {
            user: current_user,
            profile_update_request: profile_update_request,
            errors: [],
          }
        end
      else
        raise "Invalid Resolution"
      end
    rescue => e
      Rails.logger.fatal("ResolveProfileUpdateRequestMutation: #{e.class.name} > #{e.message}")
      return {
        user: nil,
        profile_update_request: nil,
        errors: ["Unable to resolve profile update request"]
      }
    end
    return {
      user: nil,
      profile_update_request: nil,
      errors: current_user.errors.full_messages + profile_update_request.errors.full_messages,
    }
  end

end
