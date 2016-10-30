class AddOrderToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :order_value, :integer, :default => 0
    remove_column :expenses, :price
    add_column :expenses, :price, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end
end
