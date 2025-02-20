class User < ApplicationRecord
  before_validation :set_default_role, on: :create
  before_update :check_role_change

  ROLES = %w[user admin manager super_admin].freeze
  
  # Associations
  has_one  :profile, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :order_items, through: :orders
  has_many :products
  has_many :products, through: :order_items
  
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product
  # Validations
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, uniqueness: true
  validates :password_digest, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }

  # Secure password handling
  has_secure_password

  # Generates a unique password reset token and saves the timestamp
  def generate_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.now.utc
    save!
  end

  # Checks if the password reset token is valid (less than 2 hours old)
  def password_token_valid?
    self.password_reset_sent_at.present? && (self.password_reset_sent_at + 2.hours) > Time.now.utc
  end

  # Resets the password
  def reset_password(new_password)
    self.password_reset_token = nil
    self.password = new_password
    save!
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Password could not be reset: #{e.message}")
    false
  end

# Fetches users who have placed an order within the last 30 days and includes their profiles
# def self.recently_active_users
#   sql = <<-SQL
#     SELECT 
#       users.id, 
#       users.email, 
#       users.username, 
#       users.role,
#       profiles.first_name
#     FROM 
#       users
#     INNER JOIN 
#       orders ON orders.user_id = users.id
#     INNER JOIN 
#       profiles ON profiles.user_id = users.id
#     WHERE 
#       orders.created_at >= NOW() - INTERVAL '30 days'
#     GROUP BY 
#       users.id, 
#       users.email,
#       users.username, 
#       users.role,
#       profiles.first_name
#   SQL
  
#   results = ActiveRecord::Base.connection.select_all(sql).to_a

#   results.map do |user_data|
#     # Build a hash that includes the `id` field
#     {
#       id: user_data['id'],
#       email: user_data['email'],
#       username: user_data['username'],
#       role: user_data['role'],
#       profile: { first_name: user_data['first_name'] }
#     }
#   end
# end


def self.recently_active_users
  User.joins(:orders, :profile)
      .where('orders.created_at >= ?', 30.days.ago)
      .distinct
end

def self.recently_active_users_with_orders
  User.joins(:profile)
      .joins(:orders)
      .where('orders.created_at >= ?', 30.days.ago)
      .select('users.*, profiles.first_name, profiles.last_name, profiles.bio, profiles.avatar, profiles.phone_number, profiles.address, orders.id AS order_id, orders.total_price, orders.status AS order_status, orders.created_at AS order_date')
      .order('orders.created_at DESC')
end


  # Role checking methods
  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def super_admin?
    role == 'super_admin'
  end

  def can_update_role?(user)
    super_admin? && !self.eql?(user)
  end

  private

  def check_role_change
    # Ensure this logic allows super_admins to change roles
    if role_changed? && !current_user.super_admin?
      errors.add(:role, "You are not allowed to change the role")
      throw(:abort)
    end
  end

    # This method can be called to mark the user as authenticated
    def mark_as_authenticated
      update(authenticated: true)
    end
  
    # This method can be called to mark the user as not authenticated
    def mark_as_not_authenticated
      update(authenticated: false)
    end

  def set_default_role
    self.role ||= "user"
  end
end
