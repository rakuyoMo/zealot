# frozen_string_literal: true

module Resolvers
  class UserResolver < BaseResolver
    type Types::UserType, null: false
    argument :id, ID

    def resolve(id:)
      user = User.find(id)
      authorize user, :show?
      user
    end
  end
end
