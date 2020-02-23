# frozen_string_literal: true

require 'eventmachine'
require_relative 'handler'

module Binance
  module Worker
    # Run eventmachine with worker
    class Run
      def call
        EM.run { Worker::Handler.new.call }
      end
    end
  end
end

Binance::Worker::Run.new.call
