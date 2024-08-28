class AddFavoriteToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :favorite, :boolean, default: false
  end
end
