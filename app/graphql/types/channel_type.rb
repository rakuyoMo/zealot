# frozen_string_literal: true

class Types::ChannelType < Types::BaseType
  description 'App\'s Channel'

  field :name, String, null: false
  field :slug, String, null: false
  field :device_type, String
  field :bundle_id, String
  field :git_url, String
  field :has_password, Boolean
  field :key, String

  def has_password
    object.password.present?
  end
end
