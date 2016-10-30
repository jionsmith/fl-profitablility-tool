# == Schema Information
#
# Table name: clients
#
#  id              :integer          not null, primary key
#  created_by_id   :integer
#  name            :string           default(""), not null
#  industry        :string
#  location        :string
#  size            :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  primary_user_id :integer
#

class Client < ActiveRecord::Base

	belongs_to :created, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :primary_user, :class_name => "User", :foreign_key => "primary_user_id"

  has_many :projects, dependent: :destroy

	enum size: {
		client_size: 0,
		start_up: 1,
		small: 2,
		medium: 3,
    large: 4,
    enterprise: 5,
	}

  def estimated_gross_info
    gross_revenue = gross_expense = gross_profit = gross_margin = 0.0
    self.projects.each do |project|
      project_gross_info = project.estimated_gross_info
      gross_revenue += project_gross_info[:gross_revenue]
      gross_expense += project_gross_info[:gross_expense]
      gross_profit += project_gross_info[:gross_profit]
    end

    if gross_revenue > 0
      gross_margin = (gross_profit / gross_revenue * 100).round(2)
    end
    {
      gross_revenue: gross_revenue,
      gross_expense: gross_expense,
      gross_profit: gross_profit,
      gross_margin: gross_margin,
    }
  end
end
