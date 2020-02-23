# frozen_string_literal: true

require 'json'

# Base app controller
class BaseController
  attr_accessor :request, :response, :params

  def initialize(request)
    @request = request
    @params = request.params
    @response = Rack::Response.new(
      [],
      200,
      {
        'Content-Type' => 'application/json',
        'Access-Control-Allow-Origin' => '*'
      }
    )
  end

  protected

  def success_response(data)
    response.status = 200
    response.body = [data&.to_json]
    response.finish
  end
end
