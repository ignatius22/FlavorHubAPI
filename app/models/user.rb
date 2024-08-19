class User < ApplicationRecord
  before_validation :set_default_role, on: :create

  ROLES = %w[user admin manager super_admin].freeze
  
  # Associations
  has_one  :profile, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :order_items, through: :orders
  has_many :products, through: :order_items

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
def self.recently_active_users
  sql = <<-SQL
    SELECT 
      users.id, 
      users.username, 
      users.role,
      profiles.first_name
    FROM 
      users
    INNER JOIN 
      orders ON orders.user_id = users.id
    INNER JOIN 
      profiles ON profiles.user_id = users.id
    WHERE 
      orders.created_at >= NOW() - INTERVAL '30 days'
    GROUP BY 
      users.id, 
      users.username, 
      users.role,
      profiles.first_name
  SQL
  ActiveRecord::Base.connection.select_all(sql).to_a
end


# Fetches users who have placed an order within the last 30 days, including their profiles and orders
def self.recently_active_users_with_orders
  sql = <<-SQL
    SELECT 
      users.id AS user_id,
      users.username,
      users.role,
      profiles.first_name,
      profiles.last_name,
      profiles.bio,
      profiles.avatar,
      profiles.phone_number,
      profiles.address,
      orders.id AS order_id,
      orders.total_price,
      orders.status AS order_status,
      orders.created_at AS order_date
    FROM 
      users
    INNER JOIN 
      orders ON orders.user_id = users.id
    INNER JOIN 
      profiles ON profiles.user_id = users.id
    WHERE 
      orders.created_at >= NOW() - INTERVAL '30 days'
    GROUP BY 
      users.id, 
      profiles.id,
      orders.id
    ORDER BY 
      orders.created_at DESC
  SQL
  ActiveRecord::Base.connection.select_all(sql).to_a
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

  def set_default_role
    self.role ||= "user"
  end
end
