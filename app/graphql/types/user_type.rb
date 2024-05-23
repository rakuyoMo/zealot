# frozen_string_literal: true

class Types::UserType < Types::BaseType
  description "User profile"

  field :username, String, null: false
  field :email, String, null: false
  field :locale, String, null: false
  field :appearance, String, null: false
  field :timezone, String, null: false
  field :role, String, null: false
end
