# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "jdoe#{n}@test.com" }
    password { 'password' }
  end
end
