class AddEstimatedFieldsToSeveralTables < ActiveRecord::Migration
  def change
    add_column :timelines, :is_estimated, :boolean, :default => true
  end
end
