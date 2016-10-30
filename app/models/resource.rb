# == Schema Information
#
# Table name: resources
#
#  id            :integer          not null, primary key
#  project_id    :integer
#  role          :string
#  name          :string
#  client_rate   :decimal(6, 2)    default(0.0)
#  resource_rate :decimal(6, 2)    default(0.0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_estimated  :boolean          default(TRUE)
#  order_value   :integer          default(0)
#
# Indexes
#
#  index_resources_on_project_id  (project_id)
#

class Resource < ActiveRecord::Base
	belongs_to :project

  before_save :validate_fields

	has_many :resource_timelines, -> { order 'resource_timelines.id ASC' }, dependent: :destroy

	# validates :store_username, :presence => true, :uniqueness => true

	validates :project_id, :presence => true
	scope :default, -> {order('created_at asc')}

  def validate_fields
    self.client_rate = 0 if self.client_rate.nil?
    self.resource_rate = 0 if self.resource_rate.nil?
  end
end
