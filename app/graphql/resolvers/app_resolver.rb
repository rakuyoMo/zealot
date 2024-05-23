# frozen_string_literal: true

module Resolvers
  class AppResolver < BaseResolver
    type Types::AppType, null: false
    argument :id, ID

    def resolve(id:)
      app = App.find(id)
      # authorize app, :show?
      app
    end
  end
end
