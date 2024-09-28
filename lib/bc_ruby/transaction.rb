require 'json'
require 'openssl'

class Transaction
  attr_accessor :sender, :receiver, :amount, :signature

  def initialize(sender, receiver, amount)
    @sender = sender
    @receiver = receiver
    @amount = amount
    @signature = nil
  end

  def to_hash
    {
      sender: @sender,
      receiver: @receiver,
      amount: @amount
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end

  # トランザクションに署名を追加
  def sign_transaction(private_key)
    raise 'マイニング報酬には署名が不要です' if @sender.nil?

    digest = OpenSSL::Digest::SHA256.new
    data = to_json
    @signature = private_key.sign(digest, data)
  end

  # 署名の検証
  def is_valid?(public_key)
    return true if @sender.nil? # マイニング報酬は署名不要

    raise '署名がありません' if @signature.nil?

    digest = OpenSSL::Digest::SHA256.new
    data = to_json
    public_key.verify(digest, @signature, data)
  end
end
