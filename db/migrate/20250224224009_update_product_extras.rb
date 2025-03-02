# db/migrate/[timestamp]_update_product_extras.rb
class UpdateProductExtras < ActiveRecord::Migration[7.1]
  def change
    change_table :product_extras do |t|
      # Add new fields
      t.decimal :price, precision: 10, scale: 2, default: 0.00
      t.string :extra_type
      t.text :description

      # Update existing columns
      t.change :name, :string, null: false
      t.change :quantity, :integer, null: false, default: 0
    end

    # Add indexes
    add_index :product_extras, [:product_id, :name], unique: true, name: "index_product_extras_uniqueness"
    add_index :product_extras, :extra_type
  end
end