# frozen_string_literal: true

class Types::CollaboratorType < GraphQL::Schema::Object
  description 'App\'s Collaborator'

  field :id, Integer, null: false
  field :username, String, null: false
  field :email, String, null: false
  field :role, String, null: false

  def id
    object.user.id
  end

  def username
    object.user.username
  end

  def email
    object.user.email
  end
end
