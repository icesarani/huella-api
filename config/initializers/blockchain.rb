# frozen_string_literal: true

Rails.application.configure do
  config.blockchain = {
    amoy_rpc_url: ENV.fetch('POLYGON_AMOY_RPC_URL', 'https://rpc-amoy.polygon.technology'),
    amoy_chain_id: 80_002,
    contract_address: ENV.fetch('SMART_CONTRACT_ADDRESS', nil),
    contract_abi: ENV.fetch('SMART_CONTRACT_ABI', '[]')
  }
end
