require_relative 'blockchain'
require_relative 'transaction'

# Initialize blockchain
bitcoin = Blockchain.new

# Mine the genesis block to give Miner1 an initial balance
puts "Mining genesis block to initialize funds..."
bitcoin.mine_pending_transactions('Miner1')

# Check initial balances
puts "After mining genesis block:"
puts "Balance of Miner1: #{bitcoin.get_balance('Miner1')}"

# Create some transactions
tx1 = Transaction.new('Miner1', 'Bob', 50)
tx2 = Transaction.new('Bob', 'Charlie', 25)

# Add transactions to the blockchain
bitcoin.add_transaction(tx1)
bitcoin.add_transaction(tx2)

# Mine the first block
puts "\nStarting the miner for the first block..."
bitcoin.mine_pending_transactions('Miner1')

# Check balances after the first mining
puts "After first mining:"
puts "Balance of Miner1: #{bitcoin.get_balance('Miner1')}"
puts "Balance of Bob: #{bitcoin.get_balance('Bob')}"
puts "Balance of Charlie: #{bitcoin.get_balance('Charlie')}"

# Create another transaction
tx3 = Transaction.new('Charlie', 'Alice', 10)
bitcoin.add_transaction(tx3)

# Mine the second block
puts "\nStarting the miner for the second block..."
bitcoin.mine_pending_transactions('Miner1')

# Check balances after the second mining
puts "After second mining:"
puts "Balance of Miner1: #{bitcoin.get_balance('Miner1')}"
puts "Balance of Alice: #{bitcoin.get_balance('Alice')}"
puts "Balance of Bob: #{bitcoin.get_balance('Bob')}"
puts "Balance of Charlie: #{bitcoin.get_balance('Charlie')}"

# Validate the blockchain
puts "\nIs blockchain valid? #{bitcoin.is_chain_valid}"
