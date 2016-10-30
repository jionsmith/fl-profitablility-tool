class AddDateAddedToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :added_date, :date, :default => Time.now
  end
end
