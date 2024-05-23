# frozen_string_literal: true

module Concerns::Authorization
  extend ActiveSupport::Concern

  def current_user
    context[:current_user]
  end
end
