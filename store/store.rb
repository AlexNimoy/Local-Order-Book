# frozen_string_literal: true

require 'redis'
require 'securerandom'
require_relative 'store_helper'

module Binance
  # Redis store
  class Store
    include StoreHelper
    attr_reader :client, :tasks, :queue

    def initialize
      @queue = ENV.fetch('WORK_QUEUE', 'binance_queue')
      @tasks = ENV.fetch('TASKS_HASH', 'binance_tasks')

      @redis_host = ENV.fetch('REDIS_HOST', 'localhost')
      @redis_port = ENV.fetch('REDIS_PORT', '6379').to_i
      @redis_db = ENV.fetch('REDIS_DB', '5').to_i

      @client = Redis.new(host: @redis_host, port: @redis_port, db: @redis_db)
    end

    def reset_store
      client.flushall
    end

    def select_all_from(table)
      client.hgetall(table)
    end

    def queue_work(value)
      key = SecureRandom.uuid
      client.multi do
        client.hset(tasks, key, value)
        client.rpush(queue, key)
      end
    end

    def next_task
      uuid = client.lpop(queue)
      return unless uuid

      task_payload = client.hget(tasks, uuid)
      client.hdel(tasks, uuid)
      task_payload
    end

    def snapshot_last_update(hash)
      client.hget("#{hash['s']}_info", 'lastUpdateId')
    end

    def save_snapshot(hash)
      client.multi do
        client.hset("#{hash['s']}_info", 'lastUpdateId', hash['lastUpdateId'])
        client.hmset("#{hash['s']}_bids", *hash['bids'])
        client.hmset("#{hash['s']}_asks", *hash['asks'])
      end
    end

    def delete_last_diff(hash)
      client.hdel("#{hash['s']}_info", 'U', 'u')
    end

    def currency_info(hash)
      client.hgetall("#{hash['s']}_info")
    end

    def save_diff(hash)
      client.multi do
        client.hmset("#{hash['s']}_info", 'U', hash['U'], 'u', hash['u'])
        update_diff_keys(hash, 'b', 'bids')
        update_diff_keys(hash, 'a', 'asks')
      end
    end

    def update_diff_keys(hash, key, postfix)
      unless zero_keys(hash, key).empty?
        client.hdel("#{hash['s']}_#{postfix}", zero_keys(hash, key))
      end
      unless correct_keys(hash, key).empty?
        client.hmset("#{hash['s']}_#{postfix}", *correct_keys(hash, key))
      end
    end
  end
end
