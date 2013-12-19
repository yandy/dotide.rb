require 'helper'

describe Dotide do
  before do
    Dotide.reset!
  end

  after do
    Dotide.reset!
  end

  it "sets defaults" do
    Dotide::Configurable.keys.each do |key|
      expect(Dotide.instance_variable_get(:"@#{key}")).to eq Dotide::Default.send(key)
    end
  end

  describe ".client" do
    it "creates an Dotide::Client" do
      expect(Dotide.client).to be_kind_of Dotide::Client
    end
    it "caches the client when the same options are passed" do
      expect(Dotide.client).to eq Dotide.client
    end
  end

  describe ".configure" do
    Dotide::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Dotide.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Dotide.instance_variable_get(:"@#{key}")).to eq key
      end
    end
  end

end
