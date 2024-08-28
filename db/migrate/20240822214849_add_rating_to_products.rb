class AddRatingToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :rating, :decimal,precision: 3, scale: 2, default: 0.0
  end
end
