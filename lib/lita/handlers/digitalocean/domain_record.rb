module Lita
  module Handlers
    class Digitalocean < Handler
      class DomainRecord < Base
        do_route /^do\s+domain\s+records?\s+create\s(?:[^\s]+\s+){2}[^\s]/i, :create, {
          t("help.domain_records.create_key") => t("help.domain_records.create_value")
        }

        do_route /^do\s+domain\s+records?\s+delete\s+[^\s]+\s+\d+$/i, :delete, {
          t("help.domain_records.delete_key") => t("help.domain_records.delete_value")
        }

        do_route /^do\s+domain\s+records?\s+edit\s+(?:[^\s]+\s+){3}[^\s]+/i, :edit, {
          t("help.domain_records.edit_key") => t("help.domain_records.edit_value")
        }

        do_route /^do\s+domain\s+records?\s+list\s+[^\s]+$/i, :list, {
          t("help.domain_records.list_key") => t("help.domain_records.list_value")
        }

        do_route /^do\s+domain\s+records?\s+show\s+[^\s]+\s+\d+$/i, :show, {
          t("help.domain_records.show_key") => t("help.domain_records.show_value")
        }
      end

      Lita.register_handler(DomainRecord)
    end
  end
end
