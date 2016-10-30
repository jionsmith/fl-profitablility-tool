class AddUserTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_type, :integer, :limit => 1, :default => 0
    add_column :users, :created_by_id, :integer, :default => 0
  end
end
