module V1
  class ClientSerializer < ActiveModel::Serializer

    attributes :id, :name, :industry, :location, :size, :project_tags
    has_many :projects, :serializer => ProjectEachSerializer

    def project_tags
      object.created.parent.project_tags
    end
  end
end
