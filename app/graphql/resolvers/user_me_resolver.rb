# frozen_string_literal: true

module Resolvers
  class UserMeResolver < BaseResolver
    type Types::UserType, null: false

    def resolve()
      user = current_user
      authorize user, :show?
      user
    end
  end
end
