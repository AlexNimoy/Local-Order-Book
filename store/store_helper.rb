# frozen_string_literal: true

module Binance
  # Helpers for store
  module StoreHelper
    ZERO_AMOUNT = '0.00000000'

    def zero_keys(hash, key)
      hash[key].map { |i| i[0] if i[1] == ZERO_AMOUNT }.compact
    end

    def correct_keys(hash, key)
      hash[key].select { |i| i[0] if i[1] != ZERO_AMOUNT }
    end
  end
end
