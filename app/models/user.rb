# app/models/user.rb
class User < ApplicationRecord
  # Constants
  ROLES = %w[user admin manager super_admin moderator].freeze
  DEFAULT_ROLE = "user".freeze

  # Associations
  has_one :profile, dependent: :destroy, inverse_of: :user
  has_many :orders, dependent: :destroy, inverse_of: :user
  has_many :order_items, through: :orders
  has_many :products, through: :order_items
  has_many :favorites, dependent: :destroy, inverse_of: :user
  has_many :favorite_products, through: :favorites, source: :product

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true, on: :create
  validates :role, presence: true, inclusion: { in: ROLES }

  # Secure Password
  has_secure_password

  # Callbacks
  before_validation :set_default_role, on: :create
  before_update :restrict_role_change, if: :role_changed?

  # Scopes
  scope :recently_active_users, -> { joins(:orders, :profile).where("orders.created_at >= ?", 30.days.ago).distinct }
  scope :recently_active_users_with_orders, -> {
    joins(:profile, :orders)
      .where("orders.created_at >= ?", 30.days.ago)
      .select("users.*, profiles.first_name, profiles.last_name, profiles.bio, profiles.avatar, 
               profiles.phone_number, profiles.address, orders.id AS order_id, orders.total_price, 
               orders.status AS order_status, orders.created_at AS order_date")
      .order("orders.created_at DESC")
  }

  # Public Methods
  def generate_password_reset_token!
    update!(password_reset_token: SecureRandom.urlsafe_base64, password_reset_sent_at: Time.current.utc)
  rescue ActiveRecord::RecordInvalid
    false
  end

  def password_token_valid?
    password_reset_sent_at&.>(Time.current.utc - 2.hours)
  end

  def reset_password(new_password)
    self.password_reset_token = nil
    self.password = new_password
    save!
  rescue ActiveRecord::RecordInvalid
    errors.add(:base, "Password reset failed")
    false
  end

  def mark_as_authenticated
    update_column(:authenticated, true)
  end

  def mark_as_not_authenticated
    update_column(:authenticated, false)
  end

  # Role Checking Methods
  %w[admin manager super_admin moderator user].each do |role|
    define_method("#{role}?") { self.role == role }
  end

  # Role Management
  def can_update_role?(target_user)
    @current_user&.super_admin? && @current_user != target_user
  end

  private

  def set_default_role
    self.role ||= DEFAULT_ROLE
  end

  def restrict_role_change
    return if can_update_role?(self)

    errors.add(:role, "Only super_admins can change roles, and you cannot change your own role")
    throw(:abort)
  end
end