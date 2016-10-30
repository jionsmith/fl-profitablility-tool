# == Schema Information
#
# Table name: projects
#
#  id            :integer          not null, primary key
#  client_id     :integer
#  created_by_id :integer
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_tag   :string           default("0")
#  gross_revenue :decimal(8, 2)    default(0.0)
#  category      :integer
#
# Indexes
#
#  index_projects_on_client_id      (client_id)
#  index_projects_on_created_by_id  (created_by_id)
#

class Project < ActiveRecord::Base

	belongs_to :client

	has_many :resources, -> { order 'resources.order_value ASC, resources.id ASC' }, dependent: :destroy
	has_many :timelines, -> { order 'timelines.id ASC' }, dependent: :destroy

  has_many :estimated_resources, -> { where(:is_estimated => true).order('order_value ASC, id ASC') }, :class_name => "Resource", :foreign_key => "project_id"
  has_many :actual_resources, -> { where(:is_estimated => false).order('order_value ASC, id ASC') }, :class_name => "Resource", :foreign_key => "project_id"

  has_many :estimated_timelines, -> { where(:is_estimated => true).order('id ASC') }, :class_name => "Timeline", :foreign_key => "project_id"
  has_many :actual_timelines, -> { where(:is_estimated => false).order('id ASC') }, :class_name => "Timeline", :foreign_key => "project_id"

	has_many :expenses, dependent: :destroy

	validates :name, :project_tag, presence: true

	enum category: {
		time_and_materials: 0,
		fixed_bid: 1,
		recurring_revenue: 2
	}

  def create_resource_timelines_by_timeline(timeline)
    self.resources.each do |resource|
      resource_timeline = ResourceTimeline.new(:resource_id => resource.id, :timeline_id => timeline.id)
      resource_timeline.save
    end
  end

  def create_resource_timelines_by_resource(resource)
    self.timelines.each do |timeline|
      resource_timeline = ResourceTimeline.new(:resource_id => resource.id, :timeline_id => timeline.id)
      resource_timeline.save
    end
  end

  def estimated_gross_info

    calculated_gross_revenue = gross_expense = gross_profit = gross_margin = 0.0
    if self.fixed_bid?
      calculated_gross_revenue = self.gross_revenue
      self.expenses.each do |expense|
        gross_expense += expense.price
      end
      gross_profit = calculated_gross_revenue - gross_expense
    else
      self.estimated_resources.each do |resource|
        resource.resource_timelines.each do |resource_timeline|
          hours = resource_timeline.hours
          calculated_gross_revenue += hours * resource.client_rate
          gross_expense += hours * resource.resource_rate
          gross_profit += hours * (resource.client_rate - resource.resource_rate)
        end
      end
    end
    
    calculated_gross_revenue = calculated_gross_revenue.round(2)
    gross_expense = gross_expense.round(2)
    gross_profit = gross_profit.round(2)
    if calculated_gross_revenue > 0
      gross_margin = (gross_profit / calculated_gross_revenue * 100).round(2)
    end
    {
      gross_revenue: calculated_gross_revenue,
      gross_expense: gross_expense,
      gross_profit: gross_profit,
      gross_margin: gross_margin,
    }
  end

  def actual_gross_info
    calculated_gross_revenue = gross_expense = gross_profit = gross_margin = 0.0
    self.actual_resources.each do |resource|
      resource.resource_timelines.each do |resource_timeline|
        hours = resource_timeline.hours
        calculated_gross_revenue += hours * resource.client_rate
        gross_expense += hours * resource.resource_rate
        gross_profit += hours * (resource.client_rate - resource.resource_rate)
      end
    end
    calculated_gross_revenue = gross_revenue.round(2)
    gross_expense = gross_expense.round(2)
    gross_profit = gross_profit.round(2)
    if calculated_gross_revenue > 0
      gross_margin = (gross_profit / calculated_gross_revenue * 100).round(2)
    end
    {
      gross_revenue: calculated_gross_revenue,
      gross_expense: gross_expense,
      gross_profit: gross_profit,
      gross_margin: gross_margin,
    }

  end
end
