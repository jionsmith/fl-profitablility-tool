# == Schema Information
#
# Table name: timelines
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_estimated :boolean          default(TRUE)
#
# Indexes
#
#  index_timelines_on_project_id  (project_id)
#

class Timeline < ActiveRecord::Base

	belongs_to :project
  has_many :resource_timelines,  -> { order 'resource_timelines.id ASC' }, dependent: :destroy

	scope :default, -> {order('created_at asc')}
end
