class Mutations::CreateProfileUpdateRequest < Mutations::BaseMutation
  null false
  argument :requestee_slug, String, required: true
  argument :field, String, required: true
  argument :value, String, required: true

  field :profile_update_request, Types::ProfileUpdateRequestType, null: true

  def resolve(
    requestee_slug:,
    field:,
    value:
  )
    current_user = context[:current_user]
    raise "Error" if !current_user

    requestee = User.friendly.find(requestee_slug)
    raise "Invalid Requestee Error" if !requestee

    begin
      profile_update_request = ProfileUpdateRequest.new(
        requestor: current_user,
        requestee: requestee,
        field: field,
        value: value,
        resolution: "pending"
      )

      if profile_update_request.save
        return {
          profile_update_request: profile_update_request,
          errors: [],
        }
      else
        return {
          profile_update_request: nil,
          errors: profile_update_request.errors.full_messages
        }
      end
    rescue => e
      Rails.logger.fatal("Mutations::CreateProfileUpdateRequest: #{e.message}")
      return {
        profile_update_request: nil,
        errors: ["Unable to create playground"]
      }
    end
  end
end
