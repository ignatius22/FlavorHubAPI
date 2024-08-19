class Product < ApplicationRecord
  has_many :product_extras, dependent: :destroy
  
  accepts_nested_attributes_for :product_extras, allow_destroy: true

  enum status: { active: 'active', inactive: 'inactive', archived: 'archived' }
  enum visibility: { visible: 'visible', hidden: 'hidden' }

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :delivery_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :archived, -> { where(status: 'archived') }
  scope :visible, -> { where(visibility: 'visible') }
  scope :hidden, -> { where(visibility: 'hidden') }
end
