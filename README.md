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

3. Set up the database:
    ```sh
    rails db:create
    rails db:migrate
    ```

4. Start the server:
    ```sh
    rails server
    ```
