class ChangeProjectTypeFieldInProjects < ActiveRecord::Migration
  def change
    change_column :projects, :project_type, :string
  end
end
