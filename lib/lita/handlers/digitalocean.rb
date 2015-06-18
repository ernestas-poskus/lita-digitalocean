module Lita
  module Handlers
    class Digitalocean < Handler
      config :access_token, type: String, required: true
    end

    Lita.register_handler(Digitalocean)
  end
end
