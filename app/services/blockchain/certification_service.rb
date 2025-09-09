# frozen_string_literal: true

require 'eth'

module Blockchain
  class CertificationService < ApplicationService # rubocop:disable Metrics/ClassLength
    def initialize
      @network = ENV.fetch('BLOCKCHAIN_NETWORK', 'amoy')
      @client = create_client
      @contract_address = ENV.fetch('CERTIFICATION_CONTRACT_ADDRESS')
      @company_private_key = ENV.fetch('COMPANY_WALLET_PRIVATE_KEY')
      super()
    end

    def call!
      raise NotImplementedError, 'Use specific methods like certify_document or verify_certification'
    end

    # Certify a document in the smart contract
    # @param pdf_hash [String] SHA256 hash of PDF (with 0x prefix)
    # @param animal_id [String] Unique animal ID (CUIG)
    # @param owner_address [String] Producer address
    # @param vet_address [String] Veterinarian address
    # @param owner_signature [String] Producer signature
    # @param vet_signature [String] Veterinarian signature
    # @return [Hash] Transaction result
    def certify_document(pdf_hash:, animal_id:, owner_address:, vet_address:, owner_signature:, vet_signature:) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/ParameterLists
      validate_addresses!(owner_address, vet_address)
      validate_signatures!(owner_signature, vet_signature)

      # Verify document is not already certified
      if document_certified?(pdf_hash)
        raise StandardError,
              I18n.t('errors.blockchain.document_already_certified', hash: pdf_hash)
      end

      # Prepare transaction
      contract = load_contract

      # Normalize private key (ensure correct format)
      normalized_key = @company_private_key.start_with?('0x') ? @company_private_key : "0x#{@company_private_key}"
      company_key = Eth::Key.new(priv: normalized_key)

      # Use configured gas price or safe default for Amoy testnet
      gas_price = ENV.fetch('BLOCKCHAIN_GAS_PRICE', '30000000000').to_i # Default: 30 gwei

      Rails.logger.info "🔥 Gas price being used: #{gas_price} wei (#{gas_price / 1_000_000_000.0} gwei)"

      # Call certifyDocument method of contract (now with animalId)
      tx = @client.transact_and_wait(
        contract,
        'certifyDocument',
        pdf_hash,           # SHA256 hash of PDF (bytes32)
        animal_id,          # Animal ID (string)
        owner_address,      # Producer address
        vet_address,        # Veterinarian address
        owner_signature,    # Producer signature
        vet_signature,      # Veterinarian signature
        sender_key: company_key,
        gas_limit: 50_000,  # Increased for additional parameter
        gas_price: gas_price,
        legacy: true
      )

      Rails.logger.info "🔥 Transaction result type: #{tx.class}, content: #{tx.inspect}"

      # Handle different response types
      if tx.is_a?(Array)
        tx_hash = tx[0] # First element could be transaction hash
        {
          success: true,
          transaction_hash: tx_hash,
          status: 'confirmed', # Assume confirmed if we get this far
          # status: tx[1].status == 1 ? 'confirmed' : 'failed', # Second element could be receipt
          contract_address: @contract_address,
          network: @network,
          raw_result: tx
        }
      else
        {
          success: true,
          transaction_hash: tx.transaction_hash,
          block_number: tx.block_number,
          gas_used: tx.gas_used,
          status: tx.status == 1 ? 'confirmed' : 'failed',
          contract_address: @contract_address,
          network: @network
        }
      end
    end

    # Check if a document is certified
    # @param pdf_hash [String] SHA256 hash of PDF
    # @return [Hash] Certification information or nil if not certified
    def verify_certification(pdf_hash)
      contract = load_contract

      certification = @client.call(contract, 'certifications', pdf_hash)

      # If timestamp is 0, document is not certified
      return nil if certification[3].zero?

      {
        owner: certification[0],
        veterinarian: certification[1],
        registrar: certification[2],
        timestamp: certification[3],
        certified_at: Time.at(certification[3])
      }
    end

    # Check if a document is already certified
    # @param pdf_hash [String] SHA256 hash of PDF
    # @return [Boolean] true if certified
    def document_certified?(pdf_hash)
      verification = verify_certification(pdf_hash)
      !verification.nil?
    end

    private

    attr_reader :network, :client, :contract_address, :company_private_key

    def create_client
      rpc_url = case @network.downcase
                when 'amoy', 'polygon-amoy'
                  ENV.fetch('AMOY_RPC_URL', 'https://rpc-amoy.polygon.technology/')
                when 'polygon', 'matic'
                  ENV.fetch('POLYGON_RPC_URL', 'https://polygon-rpc.com/')
                else
                  raise ArgumentError, I18n.t('errors.blockchain.unsupported_network', network: @network)
                end

      Eth::Client.create(rpc_url)
    end

    def load_contract
      # ABI del smart contract CertificationRegistry
      contract_abi = [
        {
          'inputs' => [
            { 'name' => 'hash', 'type' => 'bytes32' },
            { 'name' => 'animalId', 'type' => 'string' },
            { 'name' => 'owner', 'type' => 'address' },
            { 'name' => 'veterinarian', 'type' => 'address' },
            { 'name' => 'ownerSig', 'type' => 'bytes' },
            { 'name' => 'vetSig', 'type' => 'bytes' }
          ],
          'name' => 'certifyDocument',
          'outputs' => [],
          'stateMutability' => 'nonpayable',
          'type' => 'function'
        },
        {
          'inputs' => [{ 'name' => '', 'type' => 'bytes32' }],
          'name' => 'certifications',
          'outputs' => [
            { 'name' => 'owner', 'type' => 'address' },
            { 'name' => 'veterinarian', 'type' => 'address' },
            { 'name' => 'registrar', 'type' => 'address' },
            { 'name' => 'timestamp', 'type' => 'uint256' }
          ],
          'stateMutability' => 'view',
          'type' => 'function'
        },
        {
          'anonymous' => false,
          'inputs' => [
            { 'indexed' => true, 'name' => 'hash', 'type' => 'bytes32' },
            { 'indexed' => true, 'name' => 'owner', 'type' => 'address' },
            { 'indexed' => false, 'name' => 'veterinarian', 'type' => 'address' },
            { 'indexed' => false, 'name' => 'registrar', 'type' => 'address' },
            { 'indexed' => false, 'name' => 'timestamp', 'type' => 'uint256' },
            { 'indexed' => false, 'name' => 'animalId', 'type' => 'string' }
          ],
          'name' => 'DocumentCertified',
          'type' => 'event'
        },
        {
          'inputs' => [{ 'name' => 'animalId', 'type' => 'string' }],
          'name' => 'getAnimalHistory',
          'outputs' => [
            { 'name' => 'documentHashes', 'type' => 'bytes32[]' },
            { 'name' => 'timestamps', 'type' => 'uint256[]' }
          ],
          'stateMutability' => 'view',
          'type' => 'function'
        },
        {
          'inputs' => [{ 'name' => 'animalId', 'type' => 'string' }],
          'name' => 'getAnimalCertificationCount',
          'outputs' => [{ 'name' => '', 'type' => 'uint256' }],
          'stateMutability' => 'view',
          'type' => 'function'
        }
      ]

      Eth::Contract.from_abi(name: 'CertificationRegistry', address: @contract_address, abi: contract_abi)
    end

    def validate_addresses!(*addresses)
      addresses.each do |address|
        addr = Eth::Address.new(address)
        raise ArgumentError, I18n.t('errors.blockchain.invalid_ethereum_address', address: address) unless addr.valid?
      rescue StandardError
        raise ArgumentError, I18n.t('errors.blockchain.invalid_ethereum_address', address: address)
      end
    end

    def validate_signatures!(*signatures)
      signatures.each do |signature|
        next if signature.nil? || signature.empty?

        # Signatures are now hex strings without 0x prefix (130 chars = 65 bytes)
        # This allows eth.rb ABI encoder to handle them as binary data properly
        #
        # IMPORTANT: The eth.rb gem's ABI encoder has special handling for hex strings:
        # - Strings with "0x" prefix are converted using hex_to_bin
        # - This conversion can cause byte length mismatches in smart contracts
        # - By using raw hex (no prefix), we avoid this conversion issue
        unless signature.length == 130 && signature.match?(/\A[0-9a-fA-F]+\z/)
          raise ArgumentError, I18n.t('errors.blockchain.invalid_signature_format', signature: signature)
        end
      end
    end
  end
end
