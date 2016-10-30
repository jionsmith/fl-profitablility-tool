module V1
  class SessionSerializer < ActiveModel::Serializer

    attributes :id, :email, :token_type, :access_token, :name, :step, :organisation_name, :parent_organisation_name
    # has_one :assigned, :serializer => SessionSerializer

    def token_type
      'Bearer'
    end

    def parent_organisation_name
      object.parent.organisation_name
    end
  end
end
