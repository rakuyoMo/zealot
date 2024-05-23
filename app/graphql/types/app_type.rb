# frozen_string_literal: true

class Types::AppType < Types::BaseType
  description 'App'

  field :name, String, null: false
  field :schemes, [Types::SchemeType]
  field :collaborators, [Types::CollaboratorType]
end
