require 'json'
require 'pry'
require_relative '../store/store'

module Binance
  module Worker
    class Prepare
      def initialize(params, options={})
        @params = params
        @store = options[:store] || ::Binance::Store.new 
      end

      def call
        parsed = JSON.parse(@params)
        if diff?(parsed) && !old_diff?(parsed)
          if first_diff?(parsed) && first_diff_correct?(parsed)
            @store.save_diff(parsed)
          else 
            if diff_correct?(parsed)
							@store.save_diff(parsed)
            else
              p "broken"
						end
          end
          p "correct"
        end

        if snapshot?(parsed)
          @store.save_snapshot(parsed)
          @store.delete_last_diff(parsed)
        end
      end
       
      private 

      def diff?(hash)
        hash.has_key?('e')
      end

      def snapshot?(hash)
        hash.has_key?('lastUpdateId')
      end

      def last_update(hash)
        @last_update = @store.snapshot_last_update(hash)&.to_i
      end

      def old_diff?(hash)
        return true unless last_update(hash)

        hash['u'] <= last_update(hash)
      end

      def first_diff?(hash)
        !@store.currency_info(hash).has_key?('U')
      end

      def first_diff_correct?(hash)
        hash['U'] <= last_update(hash) + 1 &&
          last_update(hash) + 1 <= hash['u']
      end

      def diff_correct?(hash)
        hash['U'] == @store.currency_info(hash)["u"].to_i + 1
      end 
    end
  end
end
