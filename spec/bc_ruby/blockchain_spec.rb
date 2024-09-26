RSpec.describe Blockchain do
  before(:each) do
    @blockchain = Blockchain.new

    # 初期のマイニングで Miner1 に報酬を与え、初期残高を設定
    @blockchain.mine_pending_transactions('Miner1')
  end

  describe '#initialize' do
    it 'ジェネシスブロックを含むこと' do
      expect(@blockchain.chain.size).to eq(2) # ジェネシスブロックと初期マイニングブロック
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
    context '有効なトランザクション' do
      it 'マイニング報酬として sender=nil のトランザクションを追加できること' do
        tx = Transaction.new(nil, 'Bob', 50)
        expect { @blockchain.add_transaction(tx) }.to_not raise_error
        expect(@blockchain.pending_transactions).to include(tx)
      end

      it '有効な通常トランザクションを追加できること' do
        tx = Transaction.new('Miner1', 'Bob', 50)
        expect { @blockchain.add_transaction(tx) }.to_not raise_error
        expect(@blockchain.pending_transactions).to include(tx)
      end
    end

    context '無効なトランザクション' do
      it '送信者と受信者が両方 nil の場合は拒否すること' do
        tx = Transaction.new(nil, nil, 50)
        expect { @blockchain.add_transaction(tx) }.to raise_error('Invalid transaction: Both sender and receiver cannot be nil')
        expect(@blockchain.pending_transactions).to_not include(tx)
      end

      it '受信者が nil の場合は拒否すること' do
        tx = Transaction.new('Alice', nil, 50)
        expect { @blockchain.add_transaction(tx) }.to raise_error('Invalid transaction: Receiver cannot be nil')
        expect(@blockchain.pending_transactions).to_not include(tx)
      end

      it '送信者の残高が不足している場合は拒否すること' do
        tx = Transaction.new('Alice', 'Bob', 50) # Alice の初期残高は 0
        expect { @blockchain.add_transaction(tx) }.to raise_error('Insufficient balance')
        expect(@blockchain.pending_transactions).to_not include(tx)
      end

      it '送金額がゼロ以下の場合は拒否すること' do
        tx = Transaction.new('Miner1', 'Bob', -10)
        expect { @blockchain.add_transaction(tx) }.to raise_error('Invalid transaction: Amount must be greater than zero')
        expect(@blockchain.pending_transactions).to_not include(tx)
      end
    end

    context '複数のトランザクションがある場合' do
      it '送信者の総送金額が残高を超える場合は一部が拒否されること' do
        # Miner1 の初期残高は 100
        tx1 = Transaction.new('Miner1', 'Alice', 60)
        tx2 = Transaction.new('Miner1', 'Bob', 50) # 合計送金額は 110 > 100

        @blockchain.add_transaction(tx1)
        expect { @blockchain.add_transaction(tx2) }.to raise_error('Insufficient balance')

        # 送信者の残高を考慮して tx2 は追加されない
        expect(@blockchain.pending_transactions).to include(tx1)
        expect(@blockchain.pending_transactions).to_not include(tx2)
      end

      it '送信者の総送金額が残高以内の場合は全てが許可されること' do
        # Miner1 の初期残高は 100
        tx1 = Transaction.new('Miner1', 'Alice', 40)
        tx2 = Transaction.new('Miner1', 'Bob', 50) # 合計送金額は 90 <= 100

        @blockchain.add_transaction(tx1)
        expect { @blockchain.add_transaction(tx2) }.to_not raise_error

        expect(@blockchain.pending_transactions).to include(tx1, tx2)
      end
    end
  end

  describe '#mine_pending_transactions' do
    it 'ブロックをマイニングしチェーンに追加できること' do
      tx1 = Transaction.new('Miner1', 'Bob', 50)
      tx2 = Transaction.new('Bob', 'Charlie', 25)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)

      expect(@blockchain.chain.size).to eq(2) # ジェネシスブロックと初期マイニングブロック

      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.chain.size).to eq(3) # 新しいブロックが追加
      mined_block = @blockchain.chain.last
      expect(mined_block.transactions.size).to eq(3) # tx1, tx2, mining reward
      expect(@blockchain.pending_transactions).to be_empty # ペンディングトランザクションがリセットされている

      # マイニング報酬がブロックに含まれていることを確認
      mining_reward_tx = mined_block.transactions.find { |tx| tx.receiver == 'Miner1' && tx.sender.nil? }
      expect(mining_reward_tx).not_to be_nil
      expect(mining_reward_tx.amount).to eq(100)
    end

    it 'マイニング報酬が正しく反映されること' do
      expect(@blockchain.get_balance('Miner1')).to eq(100)

      @blockchain.mine_pending_transactions('Miner1')
      expect(@blockchain.get_balance('Miner1')).to eq(200)
    end

    it 'マイニング報酬が累積されること' do
      tx1 = Transaction.new('Miner1', 'Bob', 50)
      @blockchain.add_transaction(tx1)
      @blockchain.mine_pending_transactions('Miner1') # Miner1: 100 + 100 - 50 = 150

      tx2 = Transaction.new('Bob', 'Charlie', 25)
      @blockchain.add_transaction(tx2)
      @blockchain.mine_pending_transactions('Miner1') # Miner1: 150 + 100 = 250

      expect(@blockchain.get_balance('Miner1')).to eq(250) # 100 (初期) + 100 (1回目マイニング) + 50 (送金) + 100 (2回目マイニング)
      expect(@blockchain.get_balance('Bob')).to eq(25)      # 50 (受け取り) - 25 (送金)
      expect(@blockchain.get_balance('Charlie')).to eq(25)  # 25 (受け取り)
    end
  end

  describe '#get_balance' do
    it '正しい残高を返すこと' do
      tx1 = Transaction.new('Miner1', 'Alice', 50)
      tx2 = Transaction.new('Alice', 'Bob', 30)
      tx3 = Transaction.new('Bob', 'Charlie', 20)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)
      @blockchain.add_transaction(tx3)
      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.get_balance('Miner1')).to eq(150) # 100 (初期) - 50（送金） + 100 (マイニング報酬)
      expect(@blockchain.get_balance('Alice')).to eq(20)    # 50 (受け取り) - 30 (送金)
      expect(@blockchain.get_balance('Bob')).to eq(10)      # 30 (受け取り) - 20 (送金)
      expect(@blockchain.get_balance('Charlie')).to eq(20)  # 20 (受け取り)
    end

    it '保留中のトランザクションを考慮して残高を返すこと' do
      tx1 = Transaction.new('Miner1', 'Alice', 50)
      tx2 = Transaction.new('Alice', 'Bob', 30)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)

      # まだマイニングしていないので、保留中のトランザクションが含まれる
      expect(@blockchain.get_balance('Miner1')).to eq(100 - 50) # 初期 100 - 50 (送金)
      expect(@blockchain.get_balance('Alice')).to eq(50 - 30)    # 50 (受け取り) - 30 (送金)
      expect(@blockchain.get_balance('Bob')).to eq(30)          # 30 (受け取り)
    end
  end

  describe '#is_chain_valid' do
    it '有効なチェーンを認識すること' do
      tx1 = Transaction.new('Miner1', 'Bob', 50)
      tx2 = Transaction.new('Bob', 'Charlie', 25)
      @blockchain.add_transaction(tx1)
      @blockchain.add_transaction(tx2)
      @blockchain.mine_pending_transactions('Miner1')

      expect(@blockchain.is_chain_valid).to be true
    end

    it 'チェーンが改ざんされた場合に無効を認識すること' do
      tx1 = Transaction.new('Miner1', 'Bob', 50)
      @blockchain.add_transaction(tx1)
      @blockchain.mine_pending_transactions('Miner1')

      # チェーンを改ざん
      @blockchain.chain[1].transactions[0].amount = 1000
      expect(@blockchain.is_chain_valid).to be false
    end

    it 'チェーンがマイニング難易度を満たしていない場合に無効を認識すること' do
      tx1 = Transaction.new('Miner1', 'Bob', 50)
      @blockchain.add_transaction(tx1)
      @blockchain.mine_pending_transactions('Miner1')

      # ハッシュを手動で変更してマイニング難易度を満たしていない状態を作る
      @blockchain.chain[1].hash = 'abcd' + @blockchain.chain[1].hash[4..-1]
      expect(@blockchain.is_chain_valid).to be false
    end
  end
end
