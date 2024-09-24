require_relative '../block'
require_relative '../transaction'

RSpec.describe Block do
  describe '#initialize' do
    it '正しく初期化されること' do
      transactions = [Transaction.new('Alice', 'Bob', 50)]
      previous_hash = '0' * 64
      block = Block.new(1, transactions, previous_hash)

      expect(block.index).to eq(1)
      expect(block.transactions).to eq(transactions)
      expect(block.previous_hash).to eq(previous_hash)
      expect(block.timestamp).not_to be_nil
      expect(block.nonce).to eq(0)
      expect(block.hash).to eq(block.calculate_hash)
    end
  end

  describe '#calculate_hash' do
    it '一貫したハッシュを返すこと' do
      transactions = [Transaction.new('Alice', 'Bob', 50)]
      block = Block.new(1, transactions, '0' * 64)
      hash1 = block.calculate_hash
      hash2 = block.calculate_hash
      expect(hash1).to eq(hash2)
    end

    it '異なるブロックは異なるハッシュを持つこと' do
      transactions1 = [Transaction.new('Alice', 'Bob', 50)]
      block1 = Block.new(1, transactions1, '0' * 64)
      hash1 = block1.calculate_hash

      transactions2 = [Transaction.new('Charlie', 'Dave', 30)]
      block2 = Block.new(1, transactions2, '0' * 64)
      hash2 = block2.calculate_hash

      expect(hash1).not_to eq(hash2)
    end
  end

  describe '#mine_block' do
    it '正しい難易度のハッシュを見つけること' do
      transactions = [Transaction.new('Alice', 'Bob', 50)]
      block = Block.new(1, transactions, '0' * 64)

      expect(block.hash).not_to start_with('0000') # 初期ハッシュが難易度に達していないこと
      block.mine_block(4)
      expect(block.hash).to start_with('0000') # マイニング後のハッシュが難易度に達していること
    end
  end
end
