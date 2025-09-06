# frozen_string_literal: true

require 'eth'

module Blockchain
  class WalletCreationService < ApplicationService
    # Creates a new blockchain wallet with a unique Ethereum address,
    # private key, and mnemonic phrase. The private key and mnemonic
    # are encrypted before storage.
    #
    # @return [BlockchainWallet] the created BlockchainWallet record
    # @raise [ActiveRecord::RecordInvalid] if the wallet could not be created
    def call!
      create_wallet
    end

    private

    def create_wallet
      key = Eth::Key.new

      BlockchainWallet.create!(
        private_key: key.private_hex,
        address: key.address,
        mnemonic_phrase: generate_mnemonic
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create blockchain wallet: #{e.message}"
      raise e
    end

    def generate_mnemonic
      require 'securerandom'

      words = %w[
        abandon ability able about above absent absorb abstract absurd abuse access accident
        account accuse achieve acid acoustic acquire across act action actor actress actual
        adapt add addict address adjust admit adult advance advice aerobic affair afford
        afraid after again against age agent agree ahead aim air airport aisle alarm
        album alcohol alert alien all alley allow almost alone alpha already also alter
        always amateur amazing among amount amused analyst anchor ancient anger angle angry
        animal ankle announce annual another answer antenna antique anxiety any apart apology
      ]

      Array.new(12) { words.sample }.join(' ')
    end
  end
end
