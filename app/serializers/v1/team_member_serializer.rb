module V1
  class TeamMemberSerializer < ActiveModel::Serializer

    attributes :super, :admins, :members

    def super
      object.parent
    end

    def admins
      if object.super
        admins = object.children.where(:admin => true).order('id asc')
      else
        admins = object.parent.children.where(:admin => true).order('id asc')
      end
      admins
    end

    def members
      if object.super
        members = object.children.where.not(:admin => true).order('id asc')
      else
        members = object.parent.children.where.not(:admin => true).order('id asc')
      end
      members
    end
    
  end
end
