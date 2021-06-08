class Mutations::JoinPlayground < Mutations::BaseMutation
  null false

  argument :invite_url, String, required: true

  field :playground, Types::PlaygroundType, null: true
  field :me, Types::UserType, null: true

  def resolve(invite_url:)
    user = context[:current_user]
    url_parts = invite_url.split("/")
    playground_slug = url_parts.last
    
    if playground_slug == "100t" || playground_slug == "100T"
      playground_slug = "100-thieves"
    end

    playground = Playground.find_by_slug(playground_slug)
    if playground.blank?
      return {
        playground: nil,
        me: nil,
        errors: ["Invalid invite url"]
      }
    end
    if playground.has_member?(user)
      return {
        playground: playground,
        me: user,
        errors: []
      }
    else
      begin
        playground.add_member(user)
      rescue StandardError => e
        return {
          playground: nil,
          me: nil,
          errors: ["Unable to join playground=\"#{playground.name}\""],
        }
      end
    end

    return {
      playground: playground,
      me: user,
      errors: []
    }
  end
end
