module V1
  class ProjectSerializer < ActiveModel::Serializer

    attributes :id, :name, :client_id, :project_tag, :project_tags, :category, :revenue
    has_many :estimated_resources, :serializer => ResourceSerializer
    has_many :actual_resources, :serializer => ResourceSerializer
    has_many :estimated_timelines, :serializer => TimelineSerializer
    has_many :actual_timelines, :serializer => TimelineSerializer
    has_many :expenses, :serializer => ExpenseSerializer

    def estimated_resource_timelines
      resource_timelines = []
      if object.category != 'fixed_bid'
        object.estimated_resources.each do |resource|
          resource_timeline_list = []
          resource.resource_timelines.each do |resource_timeline|
            resource_timeline_item = {
              id: resource_timeline.id,
              resource_id: resource_timeline.resource_id,
              timeline_id: resource_timeline.timeline_id,
              hours: "#{resource_timeline.hours} hrs"
            }

            resource_timeline_list.push(resource_timeline_item)
          end
          resource_timelines.push(resource_timeline_list)
        end
      end
      resource_timelines
    end

    def project_tags
      object.client.created.parent.project_tags
    end

    def revenue
      object.gross_revenue
    end

  end
end
