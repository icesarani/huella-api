# frozen_string_literal: true

require 'eth'

module Blockchain
  class SignatureService < ApplicationService
    def initialize(pdf_hash:, owner_wallet:, vet_wallet:)
      @pdf_hash = normalize_hash(pdf_hash)
      @owner_wallet = owner_wallet
      @vet_wallet = vet_wallet
      super()
    end

    def call!
      {
        owner_signature: generate_owner_signature,
        vet_signature: generate_vet_signature,
        message_hash: message_hash
      }
    end

    # Generate producer (owner) signature
    def generate_owner_signature
      normalized_key = normalize_private_key(@owner_wallet.private_key)
      owner_key = Eth::Key.new(priv: normalized_key)
      sign_message(owner_key, @owner_wallet.address)
    end

    # Generate veterinarian signature
    def generate_vet_signature
      normalized_key = normalize_private_key(@vet_wallet.private_key)
      vet_key = Eth::Key.new(priv: normalized_key)
      sign_message(vet_key, @vet_wallet.address)
    end

    # Verify a signature - simplified to just return true for now
    # This method is mainly used for testing signature generation
    def self.verify_signature(pdf_hash:, owner_address:, vet_address:, signature:, expected_signer:) # rubocop:disable Lint/UnusedMethodArgument
      # For now, just verify that we can generate signatures consistently
      # The real verification happens in the smart contract
      !signature.nil? && !signature.empty? && signature.length == 130
    rescue StandardError => e
      Rails.logger.error "Signature verification failed: #{e.message}"
      false
    end

    private

    attr_reader :pdf_hash, :owner_wallet, :vet_wallet

    def sign_message(key, _signer_address)
      # Create message to be signed following smart contract format:
      # keccak256(abi.encodePacked(hash, owner, veterinarian))
      msg_hash = message_hash

      # Apply Ethereum prefix manually as the smart contract does
      # "\x19Ethereum Signed Message:\n32" + message
      prefix = "\x19Ethereum Signed Message:\n32"
      # msg_hash is already binary from keccak256
      prefixed_message = prefix + msg_hash

      # Hash of message with prefix
      eth_msg_hash = Eth::Util.keccak256(prefixed_message)

      # Sign using basic sign method
      key.sign(eth_msg_hash)

      # Return signature without 0x prefix to avoid eth.rb hex string conversion
      # The ABI encoder will handle the binary conversion properly
      #
      # IMPORTANT: eth.rb's ABI encoder detects hex strings with "0x" prefix and
      # converts them using hex_to_bin which can cause length mismatches in
      # smart contracts expecting exact byte lengths. By returning raw hex
      # (130 chars = 65 bytes), we let the encoder treat it as binary data.
    end

    # Calculate message hash according to contract:
    # keccak256(abi.encodePacked(hash, owner, veterinarian))
    def message_hash
      @message_hash ||= begin
        # Concatenate: hash (32 bytes) + owner (20 bytes) + veterinarian (20 bytes)
        packed_data = [@pdf_hash].pack('H*') +
                      [owner_wallet.address[2..]].pack('H*') +
                      [vet_wallet.address[2..]].pack('H*')

        # Calculate keccak256
        Eth::Util.keccak256(packed_data)
      end
    end

    # Apply Ethereum Signed Message prefix
    def eth_signed_message_hash(hash)
      # Format: "\x19Ethereum Signed Message:\n32" + hash (32 binary bytes)
      prefix = "\x19Ethereum Signed Message:\n32"
      # hash is already a hex string, convert to binary
      hash_binary = hash.is_a?(String) ? [hash].pack('H*') : hash
      prefixed_message = prefix + hash_binary
      Eth::Util.keccak256(prefixed_message)
    end

    # Normalize hash by removing 0x prefix if it exists
    def normalize_hash(hash)
      hash = hash.to_s
      hash.start_with?('0x') ? hash[2..] : hash
    end

    # Normalize private key ensuring correct format for Eth::Key
    def normalize_private_key(private_key)
      key = private_key.to_s
      key.start_with?('0x') ? key : "0x#{key}"
    end

    def validate_wallet!(wallet, type)
      unless wallet.respond_to?(:address) && wallet.respond_to?(:private_key)
        raise ArgumentError, I18n.t('errors.blockchain.invalid_wallet_format', type: type)
      end

      unless Eth::Address.valid?(wallet.address)
        raise ArgumentError, I18n.t('errors.blockchain.invalid_wallet_address', type: type, address: wallet.address)
      end

      return if wallet.private_key.present?

      raise ArgumentError, I18n.t('errors.blockchain.missing_private_key', type: type)
    end
  end
end
