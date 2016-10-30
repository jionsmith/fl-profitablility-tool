module V1
  class ResourceSerializer < ActiveModel::Serializer
    attributes :id, :role, :name, :client_rate, :resource_rate, :total_hours, :order_value

    has_many :resource_timelines, :serializer => ResourceTimelineSerializer
    def client_rate
      sprintf "$%.1f", object.client_rate.round(1)
    end

    def resource_rate
      sprintf "$%.1f", object.resource_rate.round(1)
    end

    def total_hours
      total_hours = 0
      object.resource_timelines.each do |resource_timeline|
        total_hours += resource_timeline.hours
      end
      total_hours
      sprintf "%.2f", total_hours.round(2)
    end
  end
end
