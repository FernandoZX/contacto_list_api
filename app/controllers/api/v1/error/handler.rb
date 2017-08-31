# frozen_string_literal: true

require 'active_support/concern'
module Api
  module V1
    module Error
      # :nodoc:
      module Handler
        extend ActiveSupport::Concern

        JSON_API_STATUS_CODES = {
          RECORD_NOT_FOUND: 404,
          UNPROCESSABLE_ENTITY: 422,
          PARAMETER_MISSING: 403,
          INTERNAL_SERVER_ERROR: 500,
          BAD_REQUEST: 400
        }.freeze

        included do
          rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
          rescue_from ActiveRecord::StatementInvalid, with: :show_errors
          rescue_from NoMethodError, with: :show_errors
          rescue_from ActiveModel::ForbiddenAttributesError,
                      with: :parameter_missing_exception
          rescue_from PG::CharacterNotInRepertoire, with: :bad_request
          rescue_from ActionDispatch::ParamsParser::ParseError,
                      with: :bad_request
          rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
          rescue_from RuntimeError, with: :show_errors
          rescue_from ActionController::ParameterMissing,
                      with: :missing_or_empty_params
          rescue_from ActionController::RoutingError do |_exception|
            logger.error 'Routing error occurred'
            head(JSON_API_STATUS_CODES[:RECORD_OR_RESOURCE_NOT_FOUND])
          end
        end

        private

        def manage_exceptions(code,
                              exception = nil,
                              resource_name = nil,
                              _record = nil)
          if exception
            logger.error exception.message
            logger.error exception.backtrace.to_sentence
          end
          render json: format_error(code, exception,
                                    resource_name, exception.message),
                 status: code
        end

        def format_error(code, record = nil,
                         _resource_name = nil, message = nil)
          {
            id: record.try(:id),
            status: code,
            meta: {
              message: message
            }
          }
        end

        def record_invalid(exception)
          render json: serialize_errors_object(exception.record),
                 status: :unprocessable_entity
        end

        def bad_request(exception)
          manage_exceptions(JSON_API_STATUS_CODES[:BAD_REQUEST],
                            exception,
                            controller_name.singularize)
        end

        def record_not_found(exception)
          manage_exceptions(JSON_API_STATUS_CODES[:RECORD_NOT_FOUND],
                            exception,
                            exception.model,
                            exception.try(:record))
        end

        def show_errors(exception)
          manage_exceptions(JSON_API_STATUS_CODES[:INTERNAL_SERVER_ERROR],
                            exception,
                            controller_name.singularize,
                            exception.try(:record))
        end

        def parameter_missing_exception(exception)
          manage_exceptions(JSON_API_STATUS_CODES[:UNPROCESSABLE_ENTITY],
                            exception,
                            controller_name.singularize)
        end

        def missing_or_empty_params(exception)
          manage_exceptions(JSON_API_STATUS_CODES[:PARAMETER_MISSING],
                            exception,
                            controller_name.singularize)
        end

        def serialize_errors_object(object)
          object.errors.messages.map do |field, errors|
            errors.map do |error_message|
              {
                status: 422,
                source: { pointer: "/data/attributes/#{field}" },
                meta: { message: error_message }
              }
            end
          end.flatten.first
        end
      end
    end
  end
end