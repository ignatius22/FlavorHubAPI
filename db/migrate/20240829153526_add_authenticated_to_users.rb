class AddAuthenticatedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :authenticated, :boolean, default: false, null: false
  end
end
