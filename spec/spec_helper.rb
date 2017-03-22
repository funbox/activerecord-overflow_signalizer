require 'bundler/setup'
require 'activerecord/overflow_signalizer'
require 'byebug'
require 'active_record'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

DATABASE_CONFIG_PATH = File.dirname(__FILE__) << '/database.yml'

class TestIntModel < ActiveRecord::Base
  establish_connection YAML.load_file(DATABASE_CONFIG_PATH)
  self.table_name = 'int_test'
end

TestIntModel.connection.create_table(:int_test, force: true) do |t|
  t.timestamps
end
TestIntModel.reset_column_information

class TestBigIntModel < ActiveRecord::Base
  establish_connection YAML.load_file(DATABASE_CONFIG_PATH)
  self.table_name = 'bigint_test'
end

TestBigIntModel.connection.create_table(:bigint_test, id: false, force: true) do |t|
  t.column :id, :bigint, null: false
  t.timestamps
end
TestBigIntModel.connection.execute(%Q{ ALTER TABLE "bigint_test" ADD PRIMARY KEY ("id"); })
TestBigIntModel.reset_column_information
