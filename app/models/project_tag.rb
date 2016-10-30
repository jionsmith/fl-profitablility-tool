# == Schema Information
#
# Table name: project_tags
#
#  id         :integer          not null, primary key
#  name       :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_project_tags_on_user_id  (user_id)
#

class ProjectTag < ActiveRecord::Base
  belongs_to :user
end
