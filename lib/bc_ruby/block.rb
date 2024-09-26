require 'digest'
require 'json'
require 'time'

class Block
  attr_accessor :index, :timestamp, :transactions, :previous_hash, :nonce, :hash

  def initialize(index, transactions, previous_hash = '')
    @index = index
    @timestamp = Time.now.utc.iso8601
    @transactions = transactions
    @previous_hash = previous_hash
    @nonce = 0
    @hash = calculate_hash
  end

  def calculate_hash
    block_content = {
      index: @index,
      timestamp: @timestamp,
      transactions: @transactions.map(&:to_hash),
      previous_hash: @previous_hash,
      nonce: @nonce
    }.to_json
    Digest::SHA256.hexdigest(block_content)
  end

  def mine_block(difficulty)
    target = '0' * difficulty
    while @hash[0, difficulty] != target
      @nonce += 1
      @hash = calculate_hash
    end
    puts "Block mined: #{@hash}"
  end
end
