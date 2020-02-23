require 'net/http'

module Binance
  module Listener
    module Snapshot
      class Receive
        def initialize(uri)
          @uri = uri
        end

        def call
          uri = URI(@uri)
          @res = Net::HTTP.get_response(uri)
          @res.body
        end
      end
    end
  end
end

