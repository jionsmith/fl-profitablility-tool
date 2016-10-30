class ChangeTypeFieldToProjects < ActiveRecord::Migration
  def change
  	remove_column :projects, :type
  	add_column :projects, :project_type, :integer, :limit => 1, :default => 0
  end
end
