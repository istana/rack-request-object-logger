require "spec_helper"

describe Rack::Request::Object::Logger do
  it "has a version number" do
    expect(Rack::Request::Object::Logger::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
