require 'json'

class Transaction
  attr_accessor :sender, :receiver, :amount

  def initialize(sender, receiver, amount)
    @sender = sender
    @receiver = receiver
    @amount = amount
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
end
