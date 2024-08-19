class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :title
      t.decimal :price
      t.decimal :delivery_fee
      t.integer :duration
      t.string :image

      t.timestamps
    end
  end
end
