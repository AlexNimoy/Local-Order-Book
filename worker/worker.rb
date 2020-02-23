require_relative '../store/store'
require_relative 'prepare'

module Binance
  module Worker
    class Handler
      def initialize(options={})
        @store = options[:store] || ::Binance::Store.new 
        @prepare = options[:prepare] || Worker::Prepare
      end

      def call
        loop do
          task = @store.next_task
          if task
            @prepare.new(task).call
          end
        end
      end
    end
  end
end
