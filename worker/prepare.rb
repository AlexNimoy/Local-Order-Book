# frozen_string_literal: true

require 'json'
require_relative '../store/store'

module Binance
  module Worker
    # Prepare diff data
    class Prepare
      def initialize(params, options = {})
        @params = params
        @store = options[:store] || ::Binance::Store.new
      end

      def call
        parsed = JSON.parse(@params)
        if diff?(parsed) && !old_diff?(parsed)
          if first_diff?(parsed) && first_diff_correct?(parsed)
            @store.save_diff(parsed)
          elsif diff_correct?(parsed)
            @store.save_diff(parsed)
          else
            p 'broken'
          end
        end

        return unless snapshot?(parsed)

        @store.save_snapshot(parsed)
        @store.delete_last_diff(parsed)
      end

      private

      def diff?(hash)
        hash.key?('e')
      end

      def snapshot?(hash)
        hash.key?('lastUpdateId')
      end

      def last_update(hash)
        @last_update = @store.snapshot_last_update(hash)&.to_i
      end

      def old_diff?(hash)
        return true unless last_update(hash)

        hash['u'] <= last_update(hash)
      end

      def first_diff?(hash)
        !@store.currency_info(hash).key?('U')
      end

      def first_diff_correct?(hash)
        hash['U'] <= last_update(hash) + 1 &&
          last_update(hash) + 1 <= hash['u']
      end

      def diff_correct?(hash)
        hash['U'] == @store.currency_info(hash)['u'].to_i + 1
      end
    end
  end
end
