# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtAllowlist

  has_one :producer_profile, inverse_of: :user
  has_one :vet_profile, inverse_of: :user
  has_many :jwt_allowlists, dependent: :destroy

  accepts_nested_attributes_for :producer_profile
  accepts_nested_attributes_for :vet_profile

  validate :exactly_one_profile_on_create, on: :create

  # Returns the profile associated with the user, which can be either a ProducerProfile  or a VetProfile.
  #
  # @return [ProducerProfile, VetProfile, nil] the user's profile, or nil if none exists
  def profile
    producer_profile || vet_profile
  end

  private

  # Validates that the user has exactly one profile (either producer or vet) upon creation.
  # This ensures that a user cannot be both a producer and a vet at the same time.
  #
  # @return [void]
  # @raise [ActiveModel::ValidationError] if the user has zero or more than one profile
  def exactly_one_profile_on_create
    count = 0
    count += 1 if producer_profile.present?
    count += 1 if vet_profile.present?
    return if count == 1

    errors.add(:base, I18n.t('activerecord.errors.user.attributes.profiles.invalid'))
  end
end
