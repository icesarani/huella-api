# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :producer_profile, inverse_of: :user
  has_one :vet_profile, inverse_of: :user

  def profile
    producer_profile || vet_profile
  end
end
