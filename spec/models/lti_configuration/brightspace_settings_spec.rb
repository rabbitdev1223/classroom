# frozen_string_literal: true

require "rails_helper"

RSpec.describe LtiConfiguration::BrightspaceSettings do
  let(:settings) { described_class.new }
  let(:general)  { LtiConfiguration::GenericSettings.new }

  it "platform_name should be 'Blackboard'" do
    expect(settings.platform_name).to eql("Brightspace")
  end

  it "context_memberships_url_key should be inherited" do
    expect(settings.context_memberships_url_key).to eql(general.context_memberships_url_key)
  end
end
