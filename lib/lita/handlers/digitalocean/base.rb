require "droplet_kit"
require "lita-keyword-arguments"
require "hashie"

module Lita
  module Handlers
    class Digitalocean < Handler
      class Base < Handler
        namespace "digitalocean"

        private

        def self.do_route(regexp, route_name, help, kwargs = nil)
          options = {
            command: true,
            help: help,
            restrict_to: :digitalocean_admins
          }

          options[:kwargs] = kwargs if kwargs

          route(regexp, route_name, options)
        end

        def access_token
          return config.access_token unless config.nil? || config.access_token.nil?
          return ENV['DIGITALOCEAN_ACCESS_TOKEN'] unless ENV['DIGITALOCEAN_ACCESS_TOKEN'].nil?
          raise Lita::ValidationError, t("credentials_missing")
        end

        def client
          @client ||= ::DropletKit::Client.new(access_token: access_token)
        end

        def do_call(response)
          unless access_token
            response.reply(t("credentials_missing"))
            return
          end

          do_response = yield client

          if do_response[:status] != "OK"
            response.reply(t("error", message: do_response[:message]))
            return
          end

          do_response
        end

        def format_array(array)
          %([#{array.join(",")}])
        end
      end
    end
  end
end
