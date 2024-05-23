# frozen_string_literal: true

class Queries::QueryType < Types::BaseObject
  description "The query root of this schema"

  field :app, resolver: Resolvers::AppResolver

  field :user, resolver: Resolvers::UserResolver
  field :me, resolver: Resolvers::UserMeResolver

  field :echo, String, null: false do
    description 'Testing endpoint to validate the API with'
    argument :message, String, required: false
  end

  def echo(message: nil)
    user = current_user.username
    message ||= 'hello world'
    "#{user} says #{message}"
  end
end
