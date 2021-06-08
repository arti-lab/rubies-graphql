class Mutations::BaseMutation < GraphQL::Schema::RelayClassicMutation
  field :errors, [String], null: false

  def current_user
    context[:current_user]
  end
end
