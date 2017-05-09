require 'rake/testtask'
require './tlback.rb'

desc 'Run test_unit based test'
Rake::TestTask.new do |t|
  # To run test for only one file (or file path pattern)
  #  $ bundle exec rake test TEST=test/test_specified_path.rb
  t.test_files = Dir["test/test_*.rb"]
  t.verbose = true
  t.warning = false
end

desc 'getset access_token'
task :set_token do
  set_token
end

desc 'set access_token from env'
task :set_token_from_env do
  set_token_from_env
end

desc 'restore schema'
task :restore_schema do
  

end
