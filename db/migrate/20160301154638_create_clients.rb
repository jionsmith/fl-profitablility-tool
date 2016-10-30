class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
    	t.integer :created_by_id
    	t.string :name, null: false, default: ""
    	t.string :industry
    	t.string :location
    	t.integer :size, :limit => 1, :default => 0
      t.timestamps null: false
    end
  end
end
