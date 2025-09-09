# frozen_string_literal: true

require 'ostruct'

# Support module for mocking blockchain interactions in tests
module BlockchainMocks # rubocop:disable Metrics/ModuleLength
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def with_blockchain_mocks
      before do
        setup_blockchain_mocks
      end
    end
  end

  def setup_blockchain_mocks # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    # Mock environment variables
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('BLOCKCHAIN_NETWORK', 'amoy').and_return('amoy')
    allow(ENV).to receive(:fetch).with('CERTIFICATION_CONTRACT_ADDRESS')
                                 .and_return('0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe')
    allow(ENV).to receive(:fetch).with('COMPANY_WALLET_PRIVATE_KEY')
                                 .and_return('0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef')
    allow(ENV).to receive(:fetch).with('AMOY_RPC_URL', anything).and_return('http://localhost:8545')

    # Mock Eth::Client creation
    @mock_client = instance_double(Eth::Client::Http)
    allow(Eth::Client).to receive(:create).and_return(@mock_client)

    # Add client call method for blockchain reads
    allow(@mock_client).to receive(:call) do |contract, method_name, *args|
      simulate_blockchain_call(contract, method_name, *args)
    end

    # Add client transact_and_wait method for blockchain writes
    allow(@mock_client).to receive(:transact_and_wait) do |contract, method_name, *args, **kwargs|
      simulate_blockchain_transaction(contract, method_name, *args, **kwargs)
    end

    # Mock contract loading and interactions
    mock_contract_methods
  end

  def mock_contract_methods # rubocop:disable Metrics/AbcSize ,Metrics/MethodLength
    # Mock contract instance
    @mock_contract = double('MockContract')
    allow(@mock_contract).to receive(:client=)
    allow(Eth::Contract).to receive(:from_abi).and_return(@mock_contract)

    # Mock contract call methods (for reading)
    mock_call_methods = double('ContractCallMethods')
    allow(@mock_contract).to receive(:call).and_return(mock_call_methods)

    # Mock certifications getter (returns [owner, vet, registrar, timestamp])
    allow(mock_call_methods).to receive(:certifications) do |hash|
      # Return mock certification data or empty if not found
      case hash
      when /0x123/ # Mock existing certification
        [
          '0xproducer123456789012345678901234567890',  # owner
          '0xvet123456789012345678901234567890abcd',   # veterinarian
          '0xcompany123456789012345678901234567890',   # registrar
          Time.current.to_i # timestamp
        ]
      else
        [
          '0x0000000000000000000000000000000000000000', # owner
          '0x0000000000000000000000000000000000000000', # vet
          '0x0000000000000000000000000000000000000000', # registrar
          0 # timestamp (0 means not certified)
        ]
      end
    end

    # Mock contract transaction methods (for writing)
    mock_transact_methods = double('ContractTransactMethods')
    allow(@mock_contract).to receive(:transact_and_wait).and_return(mock_transact_methods)

    # Mock certifyDocument method
    allow(mock_transact_methods).to receive(:certify_document) do |hash, owner, vet, _owner_sig, _vet_sig|
      # Simulate successful transaction
      mock_tx_receipt = OpenStruct.new(
        transaction_hash: "0x#{SecureRandom.hex(32)}",
        block_number: rand(1_000_000..9_999_999),
        gas_used: rand(21_000..100_000),
        status: 1 # Success
      )

      # You can add validation logic here if needed
      raise StandardError, 'Invalid parameters' if hash.nil? || owner.nil? || vet.nil?

      mock_tx_receipt
    end
  end

  def mock_blockchain_success(overrides = {})
    default_response = {
      success: true,
      transaction_hash: "0x#{SecureRandom.hex(32)}",
      block_number: rand(1_000_000..9_999_999),
      gas_used: rand(21_000..100_000),
      status: 'confirmed',
      contract_address: '0x20f9516fC0276BAdc43fD21755C39ed8D39a07fe',
      network: ENV.fetch('BLOCKCHAIN_NETWORK', 'amoy')
    }

    default_response.merge(overrides)
  end

  def mock_blockchain_failure(error_message = 'Network error')
    {
      success: false,
      error: error_message,
      status: 'failed'
    }
  end

  # Helper to mock signature generation
  def mock_signature_service
    mock_signatures = {
      owner_signature: SecureRandom.hex(65),  # No 0x prefix for new format
      vet_signature: SecureRandom.hex(65),    # No 0x prefix for new format
      message_hash: "0x#{SecureRandom.hex(32)}"
    }

    service_instance = instance_double(Blockchain::SignatureService)
    allow(Blockchain::SignatureService).to receive(:new).with(any_args).and_return(service_instance)
    allow(service_instance).to receive(:call!).and_return(mock_signatures)

    mock_signatures
  end

  # Helper to mock PDF generation
  def mock_pdf_generator(content = nil)
    pdf_content = content || "Mock PDF content #{SecureRandom.hex(8)}"
    allow(Utils::CattleCertificationPdfGenerator).to receive(:call).and_return(pdf_content)
    pdf_content
  end

  # Simulate blockchain transaction calls
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

  # Simulate blockchain call (read) operations
  def simulate_blockchain_call(_contract, method_name, *args)
    case method_name
    when 'certifications'
      pdf_hash = args[0]
      simulate_certification_lookup(pdf_hash)
    else
      raise ArgumentError, "Unknown contract method: #{method_name}"
    end
  end

  # Validate certification parameters
  def validate_certification_params(pdf_hash, animal_id, owner_address, vet_address, owner_signature, vet_signature) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/ParameterLists
    # Simulate smart contract validation
    raise StandardError, 'Invalid PDF hash' unless pdf_hash&.match?(/\A0x[0-9a-fA-F]{64}\z/)
    raise StandardError, 'Animal ID required' if animal_id.nil? || animal_id.empty?
    raise StandardError, 'Invalid owner address' unless valid_ethereum_address?(owner_address)
    raise StandardError, 'Invalid vet address' unless valid_ethereum_address?(vet_address)
    raise StandardError, 'Invalid owner signature' unless valid_signature?(owner_signature)
    raise StandardError, 'Invalid vet signature' unless valid_signature?(vet_signature)
  end

  # Simulate certification lookup
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

  # Validate Ethereum address
  def valid_ethereum_address?(address)
    address&.match?(/\A0x[0-9a-fA-F]{40}\z/)
  end

  # Validate signature (now without 0x prefix)
  def valid_signature?(signature)
    signature&.match?(/\A[0-9a-fA-F]{130}\z/)
  end
end

# Include in RSpec
RSpec.configure do |config|
  config.include BlockchainMocks, type: :service
  config.include BlockchainMocks, type: :request
  config.include BlockchainMocks, type: :model
end
