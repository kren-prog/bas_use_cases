# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/discord/integration'

module Implementation
  ##
  # The Implementation::NotifyDiscord class serves as a bot implementation to send messages to a
  # Discord readed from a PostgresDB table.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "FormatBirthdays"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "birthday",
  #     tag: "NotifyDiscord"
  #   }
  #
  #   options = {
  #     name: "discord bot name",
  #     webhook: "discord webhook"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::NotifyDiscord.new(options, shared_storage).execute
  #
  class NotifyDiscord < Bas::Bot::Base
    # process function to execute the Discord utility to send the PTO's notification
    #
    def process
      return { success: {} } if unprocessable_response

      response = Utils::Discord::Integration.execute(params)

      if response.code == 204
        { success: {} }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def params
      {
        name: process_options[:name],
        notification: read_response.data['notification'],
        webhook: process_options[:webhook]
      }
    end
  end
end
