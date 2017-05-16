require 'rake/testtask'
require './tlback.rb'
require 'active_support'

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
  
  pg_exec_block do
    @connection.exec(sql)
  end
end

desc 'backup_tl'
task :backup_tl do 
  backup_tl
end

desc 'set pgpass file'
task :set_pgpass do 
  settings = load_settings
  pgpass_file = [ENV["HOME"], "/", ".pgpass"].join
  File.open( pgpass_file, 'w') do |f|
    f.puts([settings["postgresql"]["host"], 
            settings["postgresql"]["port"],
            settings["postgresql"]["dbname"],
            settings["postgresql"]["user"],
            settings["postgresql"]["password"] ].join(":"))
  end
  File.chmod(0600, pgpass_file)
end
