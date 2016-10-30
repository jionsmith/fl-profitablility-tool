# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  name                   :string
#  org_name               :string
#  tags                   :text
#  super                  :boolean          default(FALSE)
#  admin                  :boolean          default(FALSE)
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  access_token           :string
#  organisation_name      :string
#  step                   :integer          default(0)
#  user_type              :integer          default(0)
#  created_by_id          :integer          default(0)
#  invite_token           :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  serialize :tags, Array

  has_many :project_tags
  has_many :clients, :class_name => "Client", :foreign_key => "created_by_id"
  has_many :all_clients, :class_name => "Client", :foreign_key => "primary_user_id"

  has_many :children, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by_id'

  # belongs_to :parent, :class_name => "User", :foreign_key => "created_by_id"

  after_create :update_access_token!

  enum user_type: {
    normal: 0,
    admin: 1,
    super_amdin: 2
  }

  def parent
    self.created_by_id == 0 ? self : User.find(self.created_by_id)
  end

  def update_access_token!
    self.access_token = generate_access_token
    self.email = self.email.downcase
    save
  end

  def generate_access_token
    loop do
      token = "#{self.id}:#{Devise.friendly_token}"
      break token unless User.where(access_token: token).first
    end
  end

  # has_many
end
