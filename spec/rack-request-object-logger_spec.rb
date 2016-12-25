require 'spec_helper'

RSpec.describe RackRequestObjectLogger do
  it "has a version number" do
    expect(RackRequestObjectLogger::VERSION).not_to be nil
  end
end
