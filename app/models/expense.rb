# == Schema Information
#
# Table name: expenses
#
#  id          :integer          not null, primary key
#  name        :string
#  job         :string
#  project_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order_value :integer          default(0)
#  price       :decimal(6, 2)    default(0.0)
#  added_date  :date             default(Fri, 24 Jun 2016)
#
# Indexes
#
#  index_expenses_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_f097e0a9ca  (project_id => projects.id)
#

class Expense < ActiveRecord::Base
  belongs_to :project
end
