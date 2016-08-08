class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  ## Relationship
  has_many :user_tokens, dependent: :destroy

  ## Validations
  validates :email, presence: true, uniqueness: true, case_sensitive: false

  ## Callbacks
  before_save do
    self.email = email.downcase if email_changed?
  end

  ## Methods
  def self.by_auth_token(token)
    user_token = UserToken.where(token: token).first
    user_token ? user_token.user : nil
  end

  def login!
    user_tokens.create
  end
end
