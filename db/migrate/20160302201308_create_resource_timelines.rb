class CreateResourceTimelines < ActiveRecord::Migration
  def change
    create_table :resource_timelines do |t|
    	t.integer :resource_id, index: true
    	t.integer :timeline_id, index: true
    	t.integer :hours, :default => 0
      t.timestamps null: false
    end
  end
end
