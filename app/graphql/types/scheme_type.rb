# frozen_string_literal: true

class Types::SchemeType < Types::BaseType
  description 'App\'s Scheme'

  field :name, String, null: false
  field :new_build_callout, Boolean
  field :retained_builds, Integer
  field :app, Types::AppType, null: false
  field :channels, [Types::ChannelType]
end
