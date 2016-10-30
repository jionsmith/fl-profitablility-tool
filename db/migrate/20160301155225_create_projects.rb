class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
    	t.integer :client_id, index: true
    	t.integer :created_by_id, index: true
    	t.string :name
    	t.string :type
    	t.timestamps null: false
    end
  end
end
