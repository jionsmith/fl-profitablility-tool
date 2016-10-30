# == Schema Information
#
# Table name: resource_timelines
#
#  id          :integer          not null, primary key
#  resource_id :integer
#  timeline_id :integer
#  hours       :decimal(6, 2)    default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_resource_timelines_on_resource_id  (resource_id)
#  index_resource_timelines_on_timeline_id  (timeline_id)
#

class ResourceTimeline < ActiveRecord::Base
	belongs_to :resource
	belongs_to :timeline

	before_save :validate_fields

	def self.get_resource_time(timeline, resource)
		resource_timeline = ResourceTimeline.where(:resource_id => resource.id, :timeline_id => timeline.id).first
		if resource_timeline.blank?
			resource_timeline = ResourceTimeline.new(:resource_id => resource.id, :timeline_id => timeline.id)
			resource_timeline.save
		end
		resource_timeline
	end

	def validate_fields
    self.hours = 0 if self.hours.nil?
  end
end
