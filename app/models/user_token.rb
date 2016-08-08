class UserToken < ApplicationRecord
  has_secure_token :token

  ## Relationships
  belongs_to :user
end