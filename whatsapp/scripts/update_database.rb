#!/usr/local/bin/ruby
# frozen_string_literal: true

require 'pg'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: 5432,
  dbname: 'bas',
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

# Read the SQL file
sql_file = '/app/db/tables.sql'
sql = File.read(sql_file)

pg_connection = PG::Connection.new(connection)

begin
  # Execute the SQL script
  pg_connection.exec(sql)
  puts 'SQL script executed successfully!'
rescue PG::Error => e
  puts e.message
ensure
  # Close the connection
  pg_connection&.close
end
