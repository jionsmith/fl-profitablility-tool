class AddOrderToResources < ActiveRecord::Migration
  def change
    add_column :resources, :order_value, :integer, :default => 0
  end
end
