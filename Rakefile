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

desc 'set settings from env'
task :set_settings_from_env do
  set_settings_from_env
end

desc 'restore schema'
task :restore_schema do
  sql = ""
  begin
    File.open('createdb.dump') do |file|
      file.read.split("\n").each do |labmen|
        sql += labmen
      end
    end
    # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  rescue IOError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  end

  settings = load_settings
  
  begin
    @connection = PG::connect(host: settings["postgresql"]["host"], user: settings["postgresql"]["user"],password: settings["postgresql"]["password"], dbname: settings["postgresql"]["dbname"], port: settings["postgresql"]["port"])
    @connection.exec(sql)
  rescue => e
    puts e.message
  ensure
    @connection.finish
  end
end

desc 'backup_tl'
task :backup_tl do 
  backup_tl
end
