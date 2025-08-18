# rails-template Ruby on Rails Application Template

This project is a template for a Ruby on Rails application, developed using Ruby version 3.3.1. If you need to change the Ruby version, look for `# CHANGE_RUBY_VERSION_HERE` in the project to find the exact places where the version needs to be updated.

## Prerequisites

- Ruby 3.3.1
- Rails
- Bundler

## Installation

Follow these steps to set up the project on your local environment:

1. Clone the repository:
    ```sh
    git clone https://github.com/your_username/your_project.git
    cd your_project
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

## Changing Ruby Version

This project is configured to use Ruby 3.3.1. If you need to change the Ruby version, look for the comment `# CHANGE_RUBY_VERSION_HERE` in the following files and update the version as needed:

- `.ruby-version`
- `Gemfile`

## Changing Solution Name

This project is named template-app. If you want to change the name of the solution, you need to search the entire solution for the following text:

- template-app
- TemplateApp
- template_app
  
Then, replace these instances with the desired text. For example, if your solution is a Crypto Wallet, you would replace them as follows:

- template-app → crypto-wallet
- TemplateApp → CryptoWallet
- template_app → crypto_wallet

## Gems Used

Below is a list of the gems used in this project. You can complete this section with the specific gems you will be using:

Testing & Security:

- rspec-rails: A testing framework that works when you do a pull request.
- faker: Generates fake data, usually used for testing.
- factory_bot: Implements factory classes, often used with Faker and RSpec.
- brakeman: A static analysis security tool.

Authentication & Authorization:

- devise: Adds authentication to your application.
- CanCanCan: (optional) Roles scheme
- Pundit: (optional) Policies scheme Object-Oriented
  
Persistence:

- pg: ORM interface to connect with PostgreSQL (we are not using SQLite).
- redis: (optional) required if you implement an instance of Redis.
- minio: (optional) local storage management.

Background Jobs:

- solid_queue: (optional) Use of PostgreSQL
- sidekiq: (optional) Use of Redis

UI:

- tailwindcss: (optional) For styling your application.
- turbo-rails: (optional) Integrates Turbo into Ruby on Rails
- stimulus-rails: (optional) Executes JavaScript with Stimulus controllers.

DevEx:

- debug: For debugging the application.
- letter_opener: A mail adapter for previewing emails.
- yard: For generating documentation.
- annotate: Writes annotations in models, fixture, and factory files based on migrations.
- rubocop: A static code analyzer and formatter.
