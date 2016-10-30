class CreateTimelines < ActiveRecord::Migration
  def change
    create_table :timelines do |t|
    	t.integer :project_id, index: true
    	t.timestamps null: false
    end
  end
end
