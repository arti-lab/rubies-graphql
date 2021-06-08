class Mutations::DeleteContest < Mutations::BaseMutation
  null false
  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType

  field :playground, Types::PlaygroundType, null: true

  def resolve(
      contest_template:
    )
    current_user = context[:current_user]
    raise "Error" if !current_user
    # Only playground owner, event host, and visor admins can delete events from playground
    is_owner = current_user == contest_template.playground.creator
    is_host = current_user == contest_template.host
    is_visor_admin = current_user.is_visor_admin
    raise "Permissions Error" if !is_owner && !is_host && !is_visor_admin
    begin
      ActiveRecord::Base.transaction do
        playground = contest_template.playground
        if contest_template.destroy!
          return {
            playground: playground,
            errors: [],
          }
        else
          return {
            playground: nil,
            errors: contest_template.errors.full_messages
          }
        end
      end
    rescue => exception
      return {
        errors: ["Unable to delete contest"]
      }
    end
  end
end
