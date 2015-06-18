require "spec_helper"

describe Lita::Handlers::Digitalocean::SSHKey, lita_handler: true do
  it { is_expected.to route_command("do ssh keys add 'foo bar' 'ssh-rsa abcdefg'").to(:add) }
  it { is_expected.to route_command("do ssh keys delete 123").to(:delete) }
  it do
    is_expected.to route_command(
      "do ssh keys edit 123 --name foo --public-key 'ssh-rsa changed'"
    ).to(:edit)
  end
  it { is_expected.to route_command("do ssh keys list").to(:list) }
  it { is_expected.to route_command("do ssh keys show 123").to(:show) }

  let(:client) { instance_double("::DropletKit::Client") }
  let(:client_ssh_keys) { instance_double("::DropletKit::SSHKeyResource") }

  before do
    robot.auth.add_user_to_group!(user, :digitalocean_admins)

    allow(::DropletKit::Client).to receive(:new).with({access_token: ENV['DIGITALOCEAN_ACCESS_TOKEN']}).and_return(client)
  end

  let(:do_list) do
    {
      status: "OK",
      ssh_keys: [
        { id: 123, name: "My Key" },
        { id: 456, name: "Your Key" }
      ]
    }
  end

  let(:do_list_empty) do
    {
      status: "OK",
      ssh_keys: []
    }
  end

  let(:do_key) do
    {
      status: "OK",
      ssh_key: {
        id: 123,
        name: "My Key",
        public_key: "ssh-rsa abcdefg"
      }
    }
  end

  describe "#add" do
    it "responds with the details of the new key" do
      allow(client_ssh_keys).to receive(:create).with({
        name: "My Key",
        public_key: "ssh-rsa abcdefg"
      }).and_return(do_key)
      send_command("do ssh keys add 'My Key' 'ssh-rsa abcdefg'")
      expect(replies.last).to eq("Created new SSH key: 123 (My Key): ssh-rsa abcdefg")
    end

    it "responds with an error message if name or public key is missing" do
      send_command("do ssh keys add foo")
      expect(replies.last).to eq("Format: do ssh keys add NAME PUBLIC_KEY")
    end
  end

  describe "#delete" do
    let(:do_delete) { { status: "OK" } }

    it "responds with a success message" do
      allow(client_ssh_keys).to receive(:delete).with("123").and_return(do_delete)
      send_command("do ssh keys delete 123")
      expect(replies.last).to eq("Deleted SSH key: 123")
    end
  end

  describe "#edit" do
    it "responds with the edited key's values" do
      allow(client_ssh_keys).to receive(:edit).with(
        "123",
        name: "My Key",
        public_key: "ssh-rsa abcdefg"
      ).and_return(do_key)
      send_command(%{do ssh keys edit 123 --name 'My Key' --public-key "ssh-rsa abcdefg"})
      expect(replies.last).to eq("Updated SSH key: 123 (My Key): ssh-rsa abcdefg")
    end
  end

  describe "#list" do
    it "returns a list of key IDs and names" do
      allow(client_ssh_keys).to receive(:list).and_return(do_list)
      send_command("do ssh keys list")
      expect(replies).to eq(["123 (My Key)", "456 (Your Key)"])
    end

    it "returns an empty state message if there are no SSH keys" do
      allow(client_ssh_keys).to receive(:list).and_return(do_list_empty)
      send_command("do ssh keys list")
      expect(replies.last).to eq("No SSH keys have been added yet.")
    end
  end

  describe "#show" do
    it "responds with the public key" do
      allow(client_ssh_keys).to receive(:show).with("123").and_return(do_key)
      send_command("do ssh keys show 123")
      expect(replies.last).to eq("123 (My Key): ssh-rsa abcdefg")
    end
  end
end
