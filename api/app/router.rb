# frozen_string_literal: true

require_relative 'controllers/depth_controller'

# Simple API router
class Router
  ROUTES = [
    {
      method: 'GET',
      path: '/api/v1/depth',
      controller: 'DepthController',
      action: :show
    }
  ].freeze

  class << self
    def route(request)
      ROUTES.each do |route|
        if route[:path] == request.path_info &&
           route[:method] == request.request_method
          return call_controller(route, request)
        end
      end

      nil
    rescue StandardError => e
      raise e
    end

    private

    def call_controller(route, request)
      constantize(route[:controller]).new(request).public_send(route[:action])
    end

    def constantize(camel_cased_word)
      Object.const_get(camel_cased_word)
    end
  end
end
