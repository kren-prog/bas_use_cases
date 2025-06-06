# frozen_string_literal: true

require 'httparty'

require 'bas/bot/base'
require 'bas/shared_storage/postgres'

module Implementation
  ##
  # The Implementation::ReviewDomainAvailability class serves as a bot implementation to read from a postgres
  # shared storage a domain requests and review its availability.
  class ReviewWebsiteAvailability < Bas::Bot::Base
    def initialize(options, shared_storage)
      super(options, shared_storage)
      @shared_storage_options = Bas::SharedStorage::Postgres.new({ write_options: process_options })
    end

    # process function to make a http request to the domain and check the status
    #
    def process
      return { success: { review: nil } } if unprocessable_response

      read_response.data['urls'].each do |url_obj|
        url = url_obj['url']
        response = availability(url)

        response.is_a?(Hash) ? write_invalid_response(response, url) : manage_response(response)
      end

      { success: { review: :ok } }
    end

    private

    def availability(url)
      HTTParty.get(url)
    rescue StandardError => e
      { error: e.message }
    end

    def manage_response(response)
      response.code == 200 ? write_ok_response(response) : write_error_response(response)
    end

    def write_ok_response(response)
      logs = request_log(response)
      write_data = { success: { notification: :ok, logs:, url: response.request.uri } }
      @shared_storage_options.write(write_data)
    end

    def write_error_response(response)
      notification = notification(response)
      logs = request_log(response)

      write_data = { success: { notification:, url: response.request.uri }.merge(logs) }

      @shared_storage_options.write(write_data)
    end

    def write_invalid_response(response, url)
      notification = invalid_notifiction(url, response[:error])
      write_data = { success: { notification:, logs: response[:error], url: } }
      @shared_storage_options.write(write_data)
    end

    def request_log(response)
      {
        headers: response.headers.inspect,
        request: response.request.inspect,
        response: response.response.inspect
      }
    end

    def notification(response)
      "⚠️ The Domain #{response.request.uri} is down with an error code of #{response.code}"
    end

    def invalid_notifiction(url, reason)
      "⚠️ The Domain #{url} is down: #{reason}"
    end
  end
end
