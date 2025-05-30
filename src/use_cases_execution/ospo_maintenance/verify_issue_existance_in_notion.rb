# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/verify_issue_existance_in_notion'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'VerifyIssueExistanceInNotion'
}

options = {
  database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::VerifyIssueExistanceInNotion.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
