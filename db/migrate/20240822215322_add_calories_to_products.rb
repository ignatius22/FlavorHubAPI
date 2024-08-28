class AddCaloriesToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :calories, :integer, default: 0, null: false
  end
end
