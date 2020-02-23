# frozen_string_literal: true

require 'faye/websocket'
require 'json'
require_relative 'snapshot/create_task'
require_relative '../config/config_loader'

module Binance
  module Listener
    # WS Listener
    class CurrencyDiff
      def initialize(config)
        @store = config[:store] || ::Binance::Store.new
        @currency_pair = config[:currency_pair]
        @pair_config = config[:pair_config] || ::Binance::ConfigLoader.instance
        @snapshot = config[:snapshot] ||
          Listener::Snapshot::CreateTask.new(
            api_url: api,
            currency_pair: @currency_pair
          )
        @ws_client = config[:ws_client] || Faye::WebSocket::Client.new(ws)
      end

      def call
        listen_ws
      end

      private

      attr_reader :ws_client

      def listen_ws
        ws_client.on :open do |_|
          # TODO: correct reset of store
          @store.reset_store
          @snapshot.call
        end

        ws_client.on :message do |event|
          @store.queue_work(event.data)
        end

        ws_client.on :close do |_|
          listen_ws
        end
      end

      def ws
        @ws ||= @pair_config.find_pair(@currency_pair)&.dig('ws')
      end

      def api
        @api ||= @pair_config.find_pair(@currency_pair)&.dig('api')
      end
    end
  end
end
