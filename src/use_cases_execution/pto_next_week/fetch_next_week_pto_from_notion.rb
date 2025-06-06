# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_next_week_pto_from_notion'
require_relative 'config'

# Configuration

options = {
  database_id: ENV.fetch('PTO_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchNextWeekPtosFromNotion'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchNextWeekPtosFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
