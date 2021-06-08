class Mutations::DeletePlayground < Mutations::BaseMutation
  null false
  argument :playground, ID, required: true, loads: Types::PlaygroundType

  field :me, Types::UserType, null: true

  def resolve(
      playground:
    )
    current_user = context[:current_user]
    raise "Error" if !current_user
    # Only playground creator and visor admins can delete a playground
    is_owner = current_user == playground.creator
    is_visor_admin = current_user.is_visor_admin

    raise "Permissions Error" if !is_owner && !is_visor_admin
    begin
      ActiveRecord::Base.transaction do
        if playground.destroy!
          return {
            me: current_user,
            errors: [],
          }
        else
          return {
            playground: nil,
            errors: playground.errors.full_messages
          }
        end
      end
    rescue => exception
      return {
        errors: ["Unable to delete playground"]
      }
    end
  end
end

