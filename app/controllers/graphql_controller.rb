# frozen_string_literal: true

class GraphqlController < ApplicationController
  before_action :validated_user!

  rescue_from Zealot::Error::Graphql::UnauthorizedError, with: :render_unauthorized

  def execute
    query = params[:query]
    variables = prepare_variables(params[:variables])
    operation_name = params[:operationName]
    result = ZealotSchema.execute(query, variables: variables, context: context, operation_name: operation_name)

    render json: result
  rescue StandardError => exception
    raise exception unless Rails.env.development?
    handle_error_in_development(exception)
  end

  private

  def render_unauthorized(exception)
    render json: { errors: [{ message: exception.message }], data: {} }, status: :unauthorized
  end

  def context
    {
      sid: session.id,
      current_user: @current_user,
      controller: self
    }
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    render json: { errors: [{ message: exception.message, backtrace: exception.backtrace }], data: {} }, status: 500
  end

  def validated_user!
    authorization = request.authorization
    raise Zealot::Error::Graphql::UnauthorizedError.new unless authorization&.downcase&.start_with?('bearer')

    token = authorization.split(' ').last
    raise Zealot::Error::Graphql::UnauthorizedError.new if token.blank?

    @current_user = User.find_by(token: token)
  end
end
