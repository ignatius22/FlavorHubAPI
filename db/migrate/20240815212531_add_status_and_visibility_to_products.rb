class AddStatusAndVisibilityToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :status, :string, default: 'active'
    add_column :products, :visibility, :string, default: 'visible'
  end
end