# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockchainTransaction, type: :model do
  subject { build(:blockchain_transaction) }

  describe 'validations' do
    it { should validate_presence_of(:transaction_hash) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:network) }
    it { should validate_presence_of(:contract_address) }
    it { should validate_uniqueness_of(:transaction_hash) }

    it 'validates status inclusion' do
      tx = build(:blockchain_transaction)
      # Skip enum validation by directly setting in database
      tx.save!
      tx.update_column(:status, 'invalid_status')
      tx.reload
      tx.valid?
      expect(tx.errors[:status]).to include('no está incluido en la lista')
    end
  end

  describe 'associations' do
    it { should have_one(:certification_document).dependent(:nullify) }
  end

  describe 'enums' do
    it {
      should define_enum_for(:status)
        .with_values(pending: 'pending', confirmed: 'confirmed',
                     failed: 'failed').with_prefix(:status).backed_by_column_of_type(:string)
    }
  end

  describe 'scopes' do
    let!(:amoy_tx) { create(:blockchain_transaction, network: 'amoy') }
    let!(:polygon_tx) { create(:blockchain_transaction, network: 'polygon') }
    let!(:contract_tx) { create(:blockchain_transaction, contract_address: '0xABC123') }
    let!(:old_tx) { create(:blockchain_transaction, created_at: 1.week.ago) }

    describe '.for_network' do
      it 'filters by network' do
        expect(BlockchainTransaction.for_network('amoy')).to include(amoy_tx)
        expect(BlockchainTransaction.for_network('amoy')).not_to include(polygon_tx)
      end
    end

    describe '.for_contract' do
      it 'filters by contract address' do
        expect(BlockchainTransaction.for_contract('0xABC123')).to include(contract_tx)
        expect(BlockchainTransaction.for_contract('0xABC123')).not_to include(amoy_tx)
      end
    end

    describe '.recent' do
      it 'orders by created_at desc' do
        recent_txs = BlockchainTransaction.recent
        expect(recent_txs.first.created_at).to be > recent_txs.last.created_at
      end
    end
  end

  describe 'status methods' do
    let(:pending_tx) { create(:blockchain_transaction, status: 'pending') }
    let(:confirmed_tx) { create(:blockchain_transaction, :confirmed) }
    let(:failed_tx) { create(:blockchain_transaction, :failed) }

    it 'returns correct status booleans' do
      expect(pending_tx.pending?).to be true
      expect(pending_tx.confirmed?).to be false
      expect(pending_tx.failed?).to be false

      expect(confirmed_tx.pending?).to be false
      expect(confirmed_tx.confirmed?).to be true
      expect(confirmed_tx.failed?).to be false

      expect(failed_tx.pending?).to be false
      expect(failed_tx.confirmed?).to be false
      expect(failed_tx.failed?).to be true
    end
  end

  describe '#blockchain_url' do
    context 'for Amoy network' do
      let(:tx) { create(:blockchain_transaction, network: 'amoy', transaction_hash: '0x123abc') }

      it 'returns Amoy PolygonScan URL' do
        expect(tx.blockchain_url).to eq('https://amoy.polygonscan.com/tx/0x123abc')
      end
    end

    context 'for Polygon network' do
      let(:tx) { create(:blockchain_transaction, network: 'polygon', transaction_hash: '0x456def') }

      it 'returns Polygon PolygonScan URL' do
        expect(tx.blockchain_url).to eq('https://polygonscan.com/tx/0x456def')
      end
    end

    context 'for Ethereum network' do
      let(:tx) { create(:blockchain_transaction, network: 'ethereum', transaction_hash: '0x789ghi') }

      it 'returns Etherscan URL' do
        expect(tx.blockchain_url).to eq('https://etherscan.io/tx/0x789ghi')
      end
    end

    context 'for unknown network' do
      let(:tx) { create(:blockchain_transaction, network: 'unknown', transaction_hash: '0x789ghi') }

      it 'returns nil' do
        expect(tx.blockchain_url).to be_nil
      end
    end
  end

  describe '#network_name' do
    it 'returns human-readable network names' do
      expect(create(:blockchain_transaction, network: 'amoy').network_name).to eq('Polygon Amoy Testnet')
      expect(create(:blockchain_transaction, network: 'polygon').network_name).to eq('Polygon Mainnet')
      expect(create(:blockchain_transaction, network: 'ethereum').network_name).to eq('Ethereum Mainnet')
      expect(create(:blockchain_transaction, network: 'custom').network_name).to eq('Custom')
    end
  end

  describe '#gas_cost_eth' do
    let(:tx) { create(:blockchain_transaction, gas_used: 21_000) }

    it 'returns gas used when present' do
      expect(tx.gas_cost_eth).to eq(21_000)
    end

    context 'when gas_used is nil' do
      let(:tx) { create(:blockchain_transaction, gas_used: nil) }

      it 'returns nil' do
        expect(tx.gas_cost_eth).to be_nil
      end
    end
  end
end
