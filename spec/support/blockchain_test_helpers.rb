# frozen_string_literal: true

require 'ostruct'

# Modern blockchain testing helpers following eth.rb patterns
module BlockchainTestHelpers # rubocop:disable Metrics/ModuleLength
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def with_blockchain_stubs
      before do
        setup_blockchain_stubs
      end
    end
  end

  def setup_blockchain_stubs
    # Stub environment configuration
    stub_blockchain_env

    # Stub Eth::Client with realistic behavior
    stub_eth_client

    # Stub contract interactions
    stub_contract_interactions
  end

  private

  def stub_blockchain_env # rubocop:disable Metrics/AbcSize
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('BLOCKCHAIN_NETWORK', 'amoy').and_return('amoy')
    allow(ENV).to receive(:fetch).with('CERTIFICATION_CONTRACT_ADDRESS')
                                 .and_return('0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe')
    allow(ENV).to receive(:fetch).with('COMPANY_WALLET_PRIVATE_KEY')
                                 .and_return('33cc0b8f3969e56485a051ff1f2c4f85c1da2517d7713dca388cbbeb3850acff')
    allow(ENV).to receive(:fetch).with('AMOY_RPC_URL', 'https://rpc-amoy.polygon.technology/').and_return('https://rpc-amoy.polygon.technology/')
    allow(ENV).to receive(:fetch).with('BLOCKCHAIN_GAS_PRICE', '30000000000').and_return('30000000000')
  end

  def stub_eth_client
    @mock_client = instance_double(Eth::Client::Http)
    allow(Eth::Client).to receive(:create).and_return(@mock_client)

    # Stub client methods following eth.rb patterns
    allow(@mock_client).to receive(:transact_and_wait) do |contract, method_name, *args, **kwargs|
      simulate_blockchain_transaction(contract, method_name, *args, **kwargs)
    end

    allow(@mock_client).to receive(:call) do |contract, method_name, *args|
      simulate_blockchain_call(contract, method_name, *args)
    end
  end

  def stub_contract_interactions
    # Stub contract creation following eth.rb from_abi pattern
    @mock_contract = double('Eth::Contract::CertificationRegistry')
    allow(Eth::Contract).to receive(:from_abi).with(
      name: 'CertificationRegistry',
      address: '0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe',
      abi: anything
    ).and_return(@mock_contract)
  end

  def simulate_blockchain_transaction(_contract, method_name, *args, **_kwargs)
    case method_name
    when 'certifyDocument'
      pdf_hash, animal_id, owner_address, vet_address, owner_signature, vet_signature = args

      # Validate parameters like a real smart contract would
      validate_certification_params(pdf_hash, animal_id, owner_address, vet_address, owner_signature, vet_signature)

      # Return transaction hash in Array format (as observed in real implementation)
      ["0x#{SecureRandom.hex(32)}"]
    else
      raise ArgumentError, "Unknown contract method: #{method_name}"
    end
  end

  def simulate_blockchain_call(_contract, method_name, *args)
    case method_name
    when 'certifications'
      pdf_hash = args[0]
      simulate_certification_lookup(pdf_hash)
    else
      raise ArgumentError, "Unknown contract method: #{method_name}"
    end
  end

  def validate_certification_params(pdf_hash, animal_id, owner_address, vet_address, owner_signature, vet_signature) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/ParameterLists
    # Simulate smart contract validation
    raise StandardError, 'Invalid PDF hash' unless pdf_hash&.match?(/\A0x[0-9a-fA-F]{64}\z/)
    raise StandardError, 'Animal ID required' if animal_id.nil? || animal_id.empty?
    raise StandardError, 'Invalid owner address' unless valid_ethereum_address?(owner_address)
    raise StandardError, 'Invalid vet address' unless valid_ethereum_address?(vet_address)
    raise StandardError, 'Invalid owner signature' unless valid_signature?(owner_signature)
    raise StandardError, 'Invalid vet signature' unless valid_signature?(vet_signature)
  end

  def simulate_certification_lookup(pdf_hash)
    # Simulate smart contract storage
    # Return [owner, veterinarian, registrar, timestamp] or zeros if not found
    if pdf_hash&.match?(/0x123/) # Mock existing certification
      [
        '0x742d35Cc6634C0532925a3b8D05B6EC21D9e4C70', # owner
        '0x8ba1f109551bD432803012645Hac136c59D8e8d9', # veterinarian
        '0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe', # registrar
        Time.current.to_i # timestamp
      ]
    else
      [
        '0x0000000000000000000000000000000000000000',
        '0x0000000000000000000000000000000000000000',
        '0x0000000000000000000000000000000000000000',
        0 # timestamp = 0 means not certified
      ]
    end
  end

  def valid_ethereum_address?(address)
    address&.match?(/\A0x[0-9a-fA-F]{40}\z/)
  end

  def valid_signature?(signature)
    signature&.match?(/\A[0-9a-fA-F]{130}\z/)
  end

  # Helper methods for test scenarios
  def expect_successful_certification
    expect(@mock_client).to receive(:transact_and_wait).and_call_original
  end

  def expect_certification_failure(error_message = 'Transaction failed')
    allow(@mock_client).to receive(:transact_and_wait).and_raise(StandardError.new(error_message))
  end

  def stub_existing_certification(pdf_hash)
    allow(@mock_client).to receive(:call).with(@mock_contract, 'certifications', pdf_hash)
                                         .and_return([
                                                       '0x742d35Cc6634C0532925a3b8D05B6EC21D9e4C70',
                                                       '0x8ba1f109551bD432803012645Hac136c59D8e8d9',
                                                       '0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe',
                                                       Time.current.to_i
                                                     ])
  end

  def stub_signature_service
    mock_signatures = {
      owner_signature: "#{'1234567890abcdef' * 8}12",  # 130 characters (65 bytes hex without 0x prefix)
      vet_signature: "#{'fedcba0987654321' * 8}34",    # 130 characters (65 bytes hex without 0x prefix)
      message_hash: "0x#{SecureRandom.hex(32)}"
    }

    service_instance = instance_double(Blockchain::SignatureService)
    allow(Blockchain::SignatureService).to receive(:new).with(any_args).and_return(service_instance)
    allow(service_instance).to receive(:call!).and_return(mock_signatures)

    mock_signatures
  end
end

# Include in RSpec
RSpec.configure do |config|
  config.include BlockchainTestHelpers, type: :service
  config.include BlockchainTestHelpers, type: :request
  config.include BlockchainTestHelpers, type: :model
end
