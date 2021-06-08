class Mutations::RemoveContestTemplateFromPlayground < Mutations::BaseMutation
  null false

  argument :playground, ID, required: true, loads: Types::PlaygroundType
  argument :contest_template, ID, required: true, loads: Types::ContestTemplateType

  field :playground, Types::PlaygroundType, null: true
  field :contest_template, Types::ContestTemplateType, null: true

  def resolve(playground:, contest_template:)
    current_user = context[:current_user]
    raise "Error" if !current_user || !current_user.is_visor_admin
    if !playground.has_contest_template?(contest_template)
      return {
          playground: nil,
          contest_template: nil,
          errors: ["Contest Template \"#{contest_template.id}\" not associated with playground \"#{playground.id}\""]
      }
    else
      begin
        playground.remove_contest_template(contest_template)
      rescue StandardError => e
        errors = ["Unable to remove contest template \"#{contest_template.id}\" from playground=\"#{playground.id}\""]
      end
    end

    if !playground.has_contest_template?(contest_template)
      return {
        playground: playground,
        contest_template: contest_template,
        errors: []
      }
    else
      return {
        playground: nil,
        contest_template: nil,
        errors: errors
      }
    end
  end

end
