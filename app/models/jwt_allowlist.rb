# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_allowlists
#
#  id         :bigint           not null, primary key
#  aud        :string
#  exp        :datetime
#  jti        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_jwt_allowlists_on_jti      (jti)
#  index_jwt_allowlists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class JwtAllowlist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  belongs_to :user

  # Clean up expired tokens
  def self.cleanup_expired_tokens
    where('exp < ?', Time.current).delete_all
  end
end
