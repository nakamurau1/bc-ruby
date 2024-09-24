require_relative '../blockchain'
require_relative '../transaction'

RSpec.describe Blockchain do
  before(:each) do
    @blockchain = Blockchain.new
  end

  describe '#initialize' do
    it 'ジェネシスブロックを含むこと' do
      expect(@blockchain.chain.size).to eq(1)
      genesis_block = @blockchain.chain.first
      expect(genesis_block.index).to eq(0)
      expect(genesis_block.previous_hash).to eq("0")
      expect(genesis_block.transactions).to be_empty
    end

    it '初期設定が正しいこと' do
      expect(@blockchain.difficulty).to eq(4)
      expect(@blockchain.pending_transactions).to be_empty
      expect(@blockchain.mining_reward).to eq(100)
    end
  end

  describe '#add_transaction' do
    it '有効なトランザクションを追加できること' do
      tx = Transaction.new('Alice', 'Bob', 50)
      @blockchain.add_transaction(tx)
      expect(@blockchain.pending_transactions).to include(tx)
    end

    it '無効なトランザクションを拒否すること' do
      tx1 = Transaction.new(nil, 'Bob', 50)
      tx2 = Transaction.new('Alice', nil, 50)
      tx3 = Transaction.new('Alice', 'Bob', -10)

      expect { @blockchain.add_transaction(tx1) }.to raise_error('Invalid transaction')
      expect { @blockchain.add_transaction(tx2) }.to raise_error('Invalid transaction')
      expect { @blockchain.add_transaction(tx3) }.to raise_error('Invalid transaction')
    end
  end

  describe '#mine_pending_transactions' do
    it 'ブロックをマイニングしチェーンに追加できること' do
      tx1 = Transaction.new('Alice', 'Bob', 50)
      tx2 = Transaction.new('Bob', 'Charlie', 25)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)

      expect(@blockchain.chain.size).to eq(1) # ジェネシスブロックのみ

      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.chain.size).to eq(2) # 新しいブロックが追加
      mined_block = @blockchain.chain.last
      expect(mined_block.transactions.size).to eq(3) # tx1, tx2, mining reward
      expect(@blockchain.pending_transactions).to be_empty # ペンディングトランザクションがリセットされている

      # マイニング報酬がブロックに含まれていることを確認
      mining_reward_tx = mined_block.transactions.find { |tx| tx.receiver == 'Miner1' }
      expect(mining_reward_tx).not_to be_nil
      expect(mining_reward_tx.amount).to eq(100)
    end

    it 'マイニング報酬が正しく反映されること' do
      @blockchain.mine_pending_transactions('Miner1')
      balance = @blockchain.get_balance('Miner1')
      expect(balance).to eq(100)
    end

    it 'マイニング報酬が累積されること' do
      @blockchain.add_transaction(Transaction.new('Alice', 'Bob', 50))
      @blockchain.mine_pending_transactions('Miner1')

      @blockchain.add_transaction(Transaction.new('Bob', 'Charlie', 25))
      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.get_balance('Miner1')).to eq(200)
    end
  end

  describe '#get_balance' do
    it '正しい残高を返すこと' do
      tx1 = Transaction.new('Alice', 'Bob', 50)
      tx2 = Transaction.new('Bob', 'Charlie', 25)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)
      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.get_balance('Alice')).to eq(-50)
      expect(@blockchain.get_balance('Bob')).to eq(25)
      expect(@blockchain.get_balance('Charlie')).to eq(25)
      expect(@blockchain.get_balance('Miner1')).to eq(100)
    end
  end

  describe '#is_chain_valid' do
    it '有効なチェーンを認識すること' do
      @blockchain.mine_pending_transactions('Miner1')
      expect(@blockchain.is_chain_valid).to be true
    end

    it 'チェーンが改ざんされた場合に無効を認識すること' do
      @blockchain.mine_pending_transactions('Miner1')
      # チェーンを改ざん
      @blockchain.chain[1].transactions[0].amount = 1000
      expect(@blockchain.is_chain_valid).to be false
    end
  end
end
