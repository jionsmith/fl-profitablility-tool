class AddPrimaryIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :primary_user_id, :integer
  end
end
