require 'spec_helper'
require 'bc_ruby/wallet'
require 'openssl'
require 'json'
require 'tempfile'

RSpec.describe Wallet do
  describe '#initialize' do
    it '初期化時に有効なキーペアを生成する' do
      wallet = Wallet.new
      expect(wallet.private_key).to be_a(OpenSSL::PKey::RSA)
      expect(wallet.public_key).to be_a(OpenSSL::PKey::RSA)
      expect(wallet.private_key.public_key.to_pem).to eq(wallet.public_key.to_pem)
    end

    it '公開鍵に基づいて一意のアドレスを生成する' do
      wallet1 = Wallet.new
      wallet2 = Wallet.new
      expect(wallet1.address).not_to eq(wallet2.address)
    end
  end

  describe '#generate_address' do
    it '公開鍵から正しいアドレスを生成する' do
      wallet = Wallet.new
      sha256 = OpenSSL::Digest::SHA256.new
      ripemd160 = OpenSSL::Digest::RIPEMD160.new
      expected_hash = ripemd160.digest(sha256.digest(wallet.public_key.to_der)).unpack1('H*')
      expect(wallet.address).to eq(expected_hash)
    end
  end

  describe '#save_to_file and .load_from_file' do
    it '暗号化ウォレットを正しく保存および読み込む' do
      wallet = Wallet.new
      passphrase = 'secure_passphrase'
      Tempfile.create('encrypted_wallet') do |file|
        wallet.save_to_file(file.path, passphrase)
        loaded_wallet = Wallet.load_from_file(file.path, passphrase)

        expect(loaded_wallet.address).to eq(wallet.address)
        expect(loaded_wallet.public_key.to_pem).to eq(wallet.public_key.to_pem)
        expect(loaded_wallet.private_key.to_pem).to eq(wallet.private_key.to_pem)
      end
    end

    it '間違ったパスフレーズで暗号化されたウォレットを読み込むとエラーが発生する' do
      wallet = Wallet.new
      correct_passphrase = 'correct_passphrase'
      incorrect_passphrase = 'wrong_passphrase'
      Tempfile.create('encrypted_wallet') do |file|
        wallet.save_to_file(file.path, correct_passphrase)
        expect { Wallet.load_from_file(file.path, incorrect_passphrase) }.to raise_error(OpenSSL::PKey::RSAError)
      end
    end
  end

  describe '#save_to_file' do
    it '有効なJSONファイルを作成する' do
      wallet = Wallet.new
      passphrase = 'secure_passphrase'
      Tempfile.create('encrypted_wallet') do |file|
        wallet.save_to_file(file.path, passphrase)
        data = JSON.parse(File.read(file.path))

        expect(data).to have_key('private_key')
        expect(data).to have_key('public_key')
        expect(data).to have_key('address')
      end
    end
  end

  describe '.load_from_file' do
    it 'ウォレットを正しく読み込む' do
      wallet = Wallet.new
      passphrase = 'secure_passphrase'
      Tempfile.create('encrypted_wallet') do |file|
        wallet.save_to_file(file.path, passphrase)
        loaded_wallet = Wallet.load_from_file(file.path, passphrase)

        expect(loaded_wallet.address).to eq(wallet.address)
        expect(loaded_wallet.public_key.to_pem).to eq(wallet.public_key.to_pem)
        expect(loaded_wallet.private_key.to_pem).to eq(wallet.private_key.to_pem)
      end
    end
  end
end
