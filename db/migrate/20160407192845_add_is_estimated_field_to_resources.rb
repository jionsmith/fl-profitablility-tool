class AddIsEstimatedFieldToResources < ActiveRecord::Migration
  def change
    add_column :resources, :is_estimated, :boolean, :default => true
  end
end
