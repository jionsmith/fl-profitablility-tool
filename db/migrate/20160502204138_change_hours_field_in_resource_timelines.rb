class ChangeHoursFieldInResourceTimelines < ActiveRecord::Migration
  def change
    change_column :resource_timelines, :hours, :decimal, :precision => 6, :scale => 2, :default => 0.00
  end
end
