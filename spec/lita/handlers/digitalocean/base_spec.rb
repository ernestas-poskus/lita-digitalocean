require "spec_helper"

handler_class = Class.new(Lita::Handlers::Digitalocean::Base) do
  namespace "digitalocean"

  route /do droplets list/, :list, command: true

  def list(response)
    do_call(response) do |client|
      { status: "error", message: "Something went wrong" }
    end
  end
end

describe handler_class, lita_handler: true do
  describe "#do_call" do
    it "responds with an error if the DigitalOcean API responds with an error" do
      send_command("do droplets list")
      expect(replies.last).to eq("DigitalOcean API error: Something went wrong")
    end

    it "responds with an error if the DigitalOcean access_token is not set" do
      ENV['DIGITALOCEAN_ACCESS_TOKEN'] = nil
      expect { send_command("do droplets list") }.to raise_exception Lita::ValidationError

      expect(replies.last).to be_nil
    end
  end
end