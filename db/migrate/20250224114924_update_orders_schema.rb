class UpdateOrdersSchema < ActiveRecord::Migration[7.1]
  def change
    # Update total_price: add null constraint and default
    change_column_null :orders, :total_price, false, 0.0
    change_column_default :orders, :total_price, from: nil, to: 0.0

    # Update status: add null constraint and default
    change_column_null :orders, :status, false, 'pending'
    change_column_default :orders, :status, from: nil, to: 'pending'

    # Optional: Update existing records (if any exist with null values)
    reversible do |dir|
      dir.up do
        Order.where(total_price: nil).update_all(total_price: 0.0)
        Order.where(status: nil).update_all(status: 'pending')
      end
    end
  end
end
