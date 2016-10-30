class AddAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
    add_column :users, :organisation_name, :string
    add_column :users, :step, :integer, :limit => 1, :default => 0
  end
end
