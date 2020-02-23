require 'redis'
require 'pry'
require 'securerandom'

module Binance
  class Store 
    def initialize
      @queue = ENV.fetch('WORK_QUEUE', 'binance_queue')
      @tasks = ENV.fetch('TASKS_HASH', 'binance_tasks')

      @redis_host = ENV.fetch('REDIS_HOST', 'localhost')
      @redis_port = ENV.fetch('REDIS_PORT', '6379').to_i
      @redis_db = ENV.fetch('REDIS_DB', '5').to_i

      @client = Redis.new(host: @redis_host, port: @redis_port, db: @redis_db)
    end

    def reset_store
      @client.flushall
		end

    # Add task uuid to queue
    # and
    # add task payload to tasks hash
    #
    # @param [String] value 
    def queue_work(value)
      key = SecureRandom.uuid
      @client.multi do
        @client.hset(@tasks, key, value)
        @client.rpush(@queue, key)
      end
    end

    def next_task
      uuid = @client.lpop(@queue)
      if uuid
        task_payload = @client.hget(@tasks, uuid)
        @client.hdel(@tasks, uuid)
        task_payload
      end
    end

    def snapshot_last_update(hash)
      @client.hget("#{hash['s']}_info", 'lastUpdateId')
    end

    def save_snapshot(hash)
      @client.multi do
        @client.hset("#{hash['s']}_info", 'lastUpdateId', hash['lastUpdateId'])
        @client.hmset("#{hash['s']}_bids", *hash['bids'])
        @client.hmset("#{hash['s']}_asks", *hash['asks'])
      end
    end

    def delete_last_diff(hash)
      @client.hdel("#{hash['s']}_info", 'U', 'u')
    end

    def currency_info(hash) 
      @client.hgetall("#{hash['s']}_info")
    end

    def save_diff(hash)
      @client.multi do
        @client.hmset("#{hash['s']}_info", 'U', hash['U'], 'u', hash['u'])

        @client.hdel("#{hash['s']}_bids", zero_keys(hash, 'b')) unless zero_keys(hash, 'b').empty?
        @client.hmset("#{hash['s']}_bids", *correct_keys(hash, 'b')) unless correct_keys(hash, 'b').empty?

        @client.hdel("#{hash['s']}_asks", zero_keys(hash, 'a')) unless zero_keys(hash, 'a').empty?
        @client.hmset("#{hash['s']}_asks", *correct_keys(hash, 'a')) unless correct_keys(hash, 'a').empty?
      end
    end

    def zero_keys(hash, key)
      hash[key].map { |i| i[0] if i[1] === "0.00000000" }.compact
		end

    def correct_keys(hash, key)
      hash[key].select { |i| i[0] if i[1] != "0.00000000" }
		end
  end
end
