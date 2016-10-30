module V1
  class ClientEachSerializer < ActiveModel::Serializer

    attributes :id, :name, :industry, :location, :size, :project_tags, :estimated_gross_info

    def project_tags
      object.created.parent.project_tags
    end

    def estimated_gross_info
      object.estimated_gross_info
    end
  end
end
