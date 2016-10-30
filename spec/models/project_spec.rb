require 'rails_helper'

RSpec.describe Project, type: :model do
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:project_tag) }
  end
end
