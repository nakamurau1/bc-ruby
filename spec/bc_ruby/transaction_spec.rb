RSpec.describe Transaction do
  describe '#initialize' do
    it '正しく初期化されること' do
      tx = Transaction.new('Alice', 'Bob', 50)
      expect(tx.sender).to eq('Alice')
      expect(tx.receiver).to eq('Bob')
      expect(tx.amount).to eq(50)
    end
  end

  describe '#to_hash' do
    it '正しいハッシュを返すこと' do
      tx = Transaction.new('Alice', 'Bob', 50)
      expected_hash = { sender: 'Alice', receiver: 'Bob', amount: 50 }
      expect(tx.to_hash).to eq(expected_hash)
    end
  end

  describe '#to_json' do
    it '正しいJSON文字列を返すこと' do
      tx = Transaction.new('Alice', 'Bob', 50)
      expected_json = '{"sender":"Alice","receiver":"Bob","amount":50}'
      expect(tx.to_json).to eq(expected_json)
    end
  end
end
