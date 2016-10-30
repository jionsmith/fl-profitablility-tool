module V1
  class ProjectEachSerializer < ActiveModel::Serializer

    attributes :id, :name, :project_tag, :estimated_gross_info
    # has_many :estimated_resources, :serializer => ResourceSerializer
    # has_many :actual_resources, :serializer => ResourceSerializer
    # has_many :estimated_timelines, :serializer => TimelineSerializer
    # has_many :actual_timelines, :serializer => TimelineSerializer

    def estimated_gross_info
      object.estimated_gross_info
    end

  end
end
