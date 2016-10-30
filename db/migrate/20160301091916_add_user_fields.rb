class AddUserFields < ActiveRecord::Migration
  def change
  	add_column :users, :username, :string
  	add_column :users, :name, :string
  	add_column :users, :org_name, :string
  	add_column :users, :tags, :text
  	add_column :users, :super, :boolean, :default => false
  	add_column :users, :admin, :boolean, :default => false
  	
    add_index :users, :username, unique: true
  end
end
