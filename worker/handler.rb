# frozen_string_literal: true

require_relative '../store/store'
require_relative 'prepare'

module Binance
  module Worker
    # Worker Handler
    class Handler
      def initialize(options = {})
        @store = options[:store] || ::Binance::Store.new
        @prepare = options[:prepare] || Worker::Prepare
      end

      def call
        loop do
          task = @store.next_task
          @prepare.new(task).call if task
        end
      end
    end
  end
end
