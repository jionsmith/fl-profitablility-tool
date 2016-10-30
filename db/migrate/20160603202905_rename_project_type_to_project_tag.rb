class RenameProjectTypeToProjectTag < ActiveRecord::Migration
  def change
    rename_table :project_types, :project_tags
    rename_column :projects, :project_type, :project_tag
  end
end
