class CreateProductExtras < ActiveRecord::Migration[7.1]
  def change
    create_table :product_extras do |t|
      t.string :name
      t.integer :quantity
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
