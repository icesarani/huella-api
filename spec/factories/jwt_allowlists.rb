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
FactoryBot.define do
  factory :jwt_allowlist do
    jti { SecureRandom.uuid }
    aud { 'user' }
    exp { 1.day.from_now }
    association :user
  end
end
