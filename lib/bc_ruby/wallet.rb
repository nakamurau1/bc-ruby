require 'openssl'
require 'json'

class Wallet
  attr_accessor :private_key, :public_key, :address

  def initialize
    generate_keys
    generate_address
  end

  # 鍵ペアを生成
  def generate_keys
    @private_key = OpenSSL::PKey::RSA.new(2048)
    @public_key = @private_key.public_key
  end

  # アドレスを生成（公開鍵のハッシュ）
  def generate_address
    sha256 = OpenSSL::Digest::SHA256.new
    ripemd160 = OpenSSL::Digest::RIPEMD160.new
    hash = ripemd160.digest(sha256.digest(@public_key.to_der))
    @address = hash.unpack1('H*')
  end

  # ウォレットをファイルに保存
  def save_to_file(file_path, passphrase)
    key_data = {
      private_key: @private_key.to_pem,
      public_key: @public_key.to_pem,
      address: @address
    }

    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    encrypted_private_key = @private_key.export(cipher, passphrase)
    key_data[:private_key] = encrypted_private_key.unpack1('H*')

    File.open(file_path, 'w') do |file|
      file.write(key_data.to_json)
    end
  end

  # ファイルからウォレットをロード
  def self.load_from_file(file_path, passphrase)
    data = JSON.parse(File.read(file_path))
    wallet = self.new_without_keys

    encrypted_private_key = [data['private_key']].pack('H*')
    wallet.private_key = OpenSSL::PKey::RSA.new(encrypted_private_key, passphrase)

    wallet.public_key = OpenSSL::PKey::RSA.new(data['public_key']).public_key
    wallet.address = data['address']
    wallet
  end

  private

  # 新しいウォレットを生成せず、キーを設定するためのメソッド
  def self.new_without_keys
    obj = allocate
    obj.private_key = nil
    obj.public_key = nil
    obj.address = nil
    obj
  end
end
