class Product < ApplicationRecord
  belongs_to :user
  has_many :product_extras, dependent: :destroy
  has_many :favorites, dependent: :destroy
  
  has_many :favorited_by_users, through: :favorites, source: :user

  accepts_nested_attributes_for :product_extras, allow_destroy: true
  

  enum status: { active: 'active', inactive: 'inactive', archived: 'archived' }
  enum visibility: { visible: 'visible', hidden: 'hidden' }

  validates :title, presence: true
  validates :title, uniqueness: { scope: [:price, :delivery_fee, :duration], message: "with these attributes already exists" }, if: :new_record_or_changed?
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :delivery_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :calories, numericality: { greater_than_or_equal_to: 0 }
  


  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :archived, -> { where(status: 'archived') }
  scope :visible, -> { where(visibility: 'visible') }
  scope :hidden, -> { where(visibility: 'hidden') }
  scope :favorites, -> { where(favorite: true) }


  # Specify the attributes that should be searchable
  def self.ransackable_attributes(auth_object = nil)
    %w[title price delivery_fee duration favorite calories created_at updated_at user_id visibility]
  end
  
  def self.ransackable_attributes(auth_object = nil)
    super + %w[status]
  end
  # Specify the associations that should be searchable
  def self.ransackable_associations(auth_object = nil)
    %w[favorited_by_users favorites product_extras user] # Add associations as needed
  end
  
  def toggle_favorite!
    update!(favorite: !favorite)
  end

  def formatted_created_at
    created_at.strftime('%B %d, %Y %I:%M %p')
  end

  def formatted_updated_at
    updated_at.strftime('%B %d, %Y %I:%M %p')
  end

  def new_record_or_changed?
    new_record? || title_changed? || price_changed? || delivery_fee_changed? || duration_changed?
  end

  private

  def valid_user_association?
    user.present?
  end

end
