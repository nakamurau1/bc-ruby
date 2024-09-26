require_relative 'block'
require_relative 'transaction'

class Blockchain
  attr_accessor :chain, :difficulty, :pending_transactions, :mining_reward

  def initialize
    @chain = [create_genesis_block]
    @difficulty = 4
    @pending_transactions = []
    @mining_reward = 100
  end

  def create_genesis_block
    Block.new(0, [], "0")
  end

  def get_latest_block
    @chain.last
  end

  # 残高を計算するメソッド
  def get_balance(address)
    balance = 0
    @chain.each do |block|
      block.transactions.each do |tx|
        if tx.sender == address
          balance -= tx.amount
        end
        if tx.receiver == address
          balance += tx.amount
        end
      end
    end
    @pending_transactions.each do |tx|
      if tx.sender == address
        balance -= tx.amount
      end
      if tx.receiver == address
        balance += tx.amount
      end
    end
    balance
  end

  def add_transaction(transaction)
    if transaction.sender.nil? && transaction.receiver.nil?
      raise 'Invalid transaction: Both sender and receiver cannot be nil'
    end

    if transaction.receiver.nil?
      raise 'Invalid transaction: Receiver cannot be nil'
    end

    if transaction.amount <= 0
      raise 'Invalid transaction: Amount must be greater than zero'
    end

    # 送信者がnilでない（マイニング報酬ではない）場合に残高を確認
    if transaction.sender
      if get_balance(transaction.sender) < transaction.amount
        raise 'Insufficient balance'
      end
    end

    @pending_transactions << transaction
  end

  def mine_pending_transactions(miner_address)
    # マイニング報酬を先に追加
    @pending_transactions << Transaction.new(nil, miner_address, @mining_reward)

    # 現在のペンディングトランザクションを含むブロックを作成
    block = Block.new(@chain.size, @pending_transactions, get_latest_block.hash)
    block.mine_block(@difficulty)
    @chain << block

    # ペンディングトランザクションをリセット
    @pending_transactions = []
  end

  def is_chain_valid
    @chain.each_with_index do |current_block, index|
      next if index == 0 # ジェネシスブロックはスキップ

      previous_block = @chain[index - 1]

      # 現在のブロックのハッシュが正しいか検証
      return false if current_block.hash != current_block.calculate_hash

      # 現在のブロックの previous_hash が前のブロックのハッシュと一致するか検証
      return false if current_block.previous_hash != previous_block.hash

      # ハッシュが難易度に応じた先頭のゼロを持つか検証
      return false unless current_block.hash.start_with?('0' * @difficulty)
    end
    true
  end
end
