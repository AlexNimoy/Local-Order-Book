# frozen_string_literal: true

require 'rack'
require 'json'
require_relative 'app/router'

# Simple Rack API app
class App
  def call(env)
    request = Rack::Request.new(env)
    default_response = Rack::Response.new(
      [{ data: 'not_found' }.to_json],
      404,
      { 'Content-Type' => 'application/json' }
    )

    begin
      Router.route(request) || default_response.finish
    rescue StandardError => e
      Rack::Response.new(
        [{ data: 'server_error', message: e.message }.to_json],
        500,
        { 'Content-Type' => 'application/json' }
      ).finish
    end
  end
end
