# Huella Rural API — README

Welcome to the **Huella Rural API**, the backend that powers:
- The **mobile app for veterinarians** (view certification requests, annotate findings, issue certificates).
- The **producer portal** (create certification requests, upload lot info, sign).
- The **public viewer** for issued certificates (transparency + on-chain verification).

## Architecture & Stack

**Domain (short):**
- Producer, Veterinarian, Lot, Animal, Certification Request, Certificate, Media (photos/videos), AI Annotations, Blockchain Proof.

**Tech (proposed):**
- **API**: Ruby on Rails 7.x (API-only)
- **DB**: PostgreSQL 17+
- **Blockchain**: Polygon (Amoy testnet / Mainnet). Smart contract `CertificationRegistry` (stores `bytes32` PDF hash + addresses + ECDSA signatures).
- **Docs**: OpenAPI 3.1 (Swagger UI at `/docs`)

## Installation

Follow these steps to set up the project on your local environment:

1. Clone the repository:
    ```sh
    git clone https://github.com/icesarani/huella-api.git
    cd huella-api
    ```

2. Install the required gems:
    ```sh
    bundle install
    ```

3. Configure environment variables:
    ```sh
    cp .env.sample .env
    # Edit .env and set your encryption keys (see Environment Variables section below)
    ```

4. Set up the database:
    ```sh
    rails db:create
    rails db:migrate
    ```

5. Start the server:
    ```sh
    rails server
    ```

## Environment Variables

This application requires the following environment variables to be set:

### ActiveRecord Encryption (Required)
These keys are used to encrypt sensitive data in the database (blockchain wallet private keys and mnemonic phrases):

```bash
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your_primary_key_here
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your_deterministic_key_here
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your_key_derivation_salt_here
```

**To generate new encryption keys:**
```bash
bundle exec rails db:encryption:init
```

### Blockchain Configuration (Optional)
```bash
POLYGON_AMOY_RPC_URL=https://rpc-amoy.polygon.technology
SMART_CONTRACT_ADDRESS=0x...
```

## GitHub Actions / CI Setup

For continuous integration to work properly, the following **GitHub repository secrets** must be configured:

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets:
   - `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`
   - `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY` 
   - `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`

**⚠️ Important:** Use different encryption keys for each environment (development, test, production) for security.
