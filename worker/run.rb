require 'eventmachine'
require_relative 'worker'

module Binance
  module Worker
    class Run
      def call
        EM.run {
          Worker::Handler.new.call
        }
      end
    end
  end
end

Binance::Worker::Run.new.call
