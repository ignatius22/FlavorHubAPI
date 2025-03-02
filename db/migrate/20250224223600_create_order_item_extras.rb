# db/migrate/[timestamp]_create_order_item_extras.rb
class CreateOrderItemExtras < ActiveRecord::Migration[7.1]
  def change
    create_table :order_item_extras do |t|
      # Foreign Keys
      t.references :order_item, null: false, foreign_key: true, index: true
      t.references :product_extra, null: false, foreign_key: true, index: true

      # Attributes
      t.integer :quantity, null: false
      t.decimal :price_at_time, precision: 10, scale: 2, null: false

      # Timestamps
      t.timestamps
    end

    # Additional Indexes
    add_index :order_item_extras, [:order_item_id, :product_extra_id], unique: true, name: "index_order_item_extras_uniqueness"
  end
end