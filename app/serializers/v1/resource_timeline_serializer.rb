module V1
  class ResourceTimelineSerializer < ActiveModel::Serializer
    # attributes :project_resource

    attributes :id, :hours

    def hours
      "#{object.hours} hrs"
    end

    def project_resource
    	ret = {}
    	ret[:weekly_timelines] = []


    	timelines = object.timelines.default
    	resources = object.resources.default
    	# timelines.each_with_index do |timeline, index|
    	# 	weekly_timeline = {}
    	# 	weekly_timeline[:timeline_id] = timeline.id
    	# 	weekly_timeline[:weekly_number] = "#{(index + 1).to_s}st Week"
    	# 	weekly_timeline[:resource_timelines] = []
    	# 	resources.each do |resource|
    	# 		resource_timeline = ResourceTimeline.get_resource_time(timeline, resource)
    	# 		weekly_timeline[:resource_timelines].push({:resource_timeline_id => resource_timeline.id, :hours => resource_timeline.hours})
    	# 	end
    	# 	ret[:weekly_timelines].push(weekly_timeline)
    	# end

    	total_revenue = total_expense = total_profit = total_margin = 0
    	resources.each do |resource|
    		resource_total_timeline = {}
    		resource_total_timeline[:resource_id] = resource.id
    		resource_total_timeline[:resource_role] = resource.role
    		resource_total_timeline[:resource_name] = resource.name
    		resource_total_timeline[:resource_client_rate] = resource.client_rate
    		resource_total_timeline[:resource_resource_rate] = resource.resource_rate
    		resource_total_timeline[:timelines] = []
    		total_timeline_hours = 0

    		timelines.each_with_index do |timeline, index|
    			resource_timeline = ResourceTimeline.get_resource_time(timeline, resource)
    			resource_total_timeline[:timelines].push({:resource_timeline_id => resource_timeline.id, :hours => resource_timeline.hours})
    			total_timeline_hours += resource_timeline.hours
    		end
    		resource_total_timeline[:resource_total_hours] = total_timeline_hours
    		resource_total_revenue = total_timeline_hours * resource.client_rate
    		resource_total_expense = total_timeline_hours * resource.resource_rate
    		resource_total_profit = resource_total_revenue - resource_total_expense
    		if resource_total_revenue != 0
    			resource_total_margin = ((resource_total_profit / resource_total_revenue) * 100).round(0)
    		else
    			resource_total_margin = 0
    		end

    		resource_total_timeline[:resource_total_revenue] = resource_total_revenue
    		resource_total_timeline[:resource_total_expense] = resource_total_expense
    		resource_total_timeline[:resource_total_profit] = resource_total_profit
    		resource_total_timeline[:resource_total_margin] = resource_total_margin

    		total_revenue += resource_total_revenue
    		total_expense += resource_total_expense
    		total_profit += resource_total_profit
    		ret[:weekly_timelines].push(resource_total_timeline)
    	end

    	if total_revenue != 0
    		total_margin = ((total_profit / total_revenue) * 100).round(0)
    	end

    	ret[:project_infor] = {}
    	ret[:project_infor][:name] = object.name
    	ret[:project_infor][:project_tag] = object.project_tag
    	ret[:project_infor][:total_revenue] = total_revenue
    	ret[:project_infor][:total_expense] = total_expense
    	ret[:project_infor][:total_profit] = total_profit
    	ret[:project_infor][:total_revenue] = total_revenue

    	# ret[:resources] = []
    	# resources.each do |resource|
    	# 	ret[:resources].push({:id => resource.id, :role => resource.role, :name => resource.name, :client_rate => resource.client_rate, :resource_rate => resource.resource_rate})
    	# end

    	# ret[:project_infor] = {}
    	# ret[:project_infor][:name] = object.name
    	# ret[:project_infor][:project_tag] = object.project_tag

    	# financials
    	# resources.each do |resource|
    	# 	resource.resource_timelines.each do |resource_timeline|

    	# 	end
    	# end
    	ret
    end


  end
end
