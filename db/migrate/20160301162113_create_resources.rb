class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
    	t.integer :project_id, index: true
    	t.string :role
    	t.string :name
    	t.decimal :client_rate, :precision => 6, :scale => 2, :default => 0.0
    	t.decimal :resource_rate, :precision => 6, :scale => 2, :default => 0.0
      t.timestamps null: false
    end
  end
end
