RSpec.describe Transaction do
  describe '#initialize' do
    it '正しく初期化されること' do
      tx = Transaction.new('Alice', 'Bob', 50)
      expect(tx.sender).to eq('Alice')
      expect(tx.receiver).to eq('Bob')
      expect(tx.amount).to eq(50)
      expect(tx.signature).to be_nil
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

  describe '#sign_transaction' do
    it 'トランザクションに署名を追加できること' do
      wallet = Wallet.new
      tx = Transaction.new(wallet.address, 'Bob', 50)
      tx.sign_transaction(wallet.private_key)
      expect(tx.signature).not_to be_nil
    end

    it 'マイニング報酬には署名を追加しないこと' do
      tx = Transaction.new(nil, 'Bob', 100)
      expect {tx.sign_transaction(nil) }.to raise_error('マイニング報酬には署名が不要です')
    end
  end

  describe '#is_valid?' do
    it '有効な署名を検証できること' do
      wallet = Wallet.new
      tx = Transaction.new(wallet.address, 'Bob', 50)
      tx.sign_transaction(wallet.private_key)
      expect(tx.is_valid?(wallet.public_key)).to be true
    end

    it '無効な署名を検証できること' do
      wallet1 = Wallet.new
      wallet2 = Wallet.new
      tx = Transaction.new(wallet1.address, 'Bob', 50)
      tx.sign_transaction(wallet2.private_key) # 間違った秘密鍵で署名
      expect(tx.is_valid?(wallet1.public_key)).to be false
    end

    it 'マイニング報酬は常に有効であること' do
      tx = Transaction.new(nil, 'Bob', 100)
      expect(tx.is_valid?(nil)).to be true
    end
  end
end
