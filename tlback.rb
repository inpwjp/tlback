##!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'twitter'
require 'date'
require 'pg'
require 'yaml'


def load_settings
  begin 
    YAML.load_file('settings.yml')
  rescue
    {}
  end
end

def save_settings(settings = Yaml.new)
  File.open('settings.yml', 'w') do |f|
    f.write settings.to_yaml
  end
end

def set_settings_from_env
  settings = load_settings
  
  settings["twitter"] ||= {}
  settings["postgresql"] ||= {}
  settings["twitter"]["consumer_key"] = ENV["TWITTER_CONSUMER_KEY"] if ENV["TWITTER_CONSUMER_KEY"]
  settings["twitter"]["consumer_secret"] = ENV["TWITTER_CONSUMER_SECRET"] if ENV["TWITTER_CONSUMER_SECRET"]
  settings["twitter"]["token"] = ENV["TWITTER_TOKEN"] if ENV["TWITTER_TOKEN"]
  settings["twitter"]["secret"] = ENV["TWITTER_TOKEN"] if ENV["TWITTER_TOKEN"]
  settings["postgresql"]["user"] = ENV["PSQL_USER"] if ENV["PSQL_USER"]
  settings["postgresql"]["host"] = ENV["PSQL_HOST"] if ENV["PSQL_HOST"]
  settings["postgresql"]["password"] = ENV["PSQL_PASSWORD"] if ENV["PSQL_PASSWORD"]
  settings["postgresql"]["dbname"] = ENV["PSQL_DBNAME"] if ENV["PSQL_DBNAME"]
  settings["postgresql"]["port"] = ENV["PSQL_PORT"] if ENV["PSQL_PORT"]

  save_settings(settings)
end

def set_token
  settings = load_settings

  consumer = OAuth::Consumer.new(
    settings["twitter"]["consumer_key"],
    settings["twitter"]["consumer_secret"] ,
    :site => "https://api.twitter.com/"
  )

  request_token = consumer.get_request_token
  puts request_token.authorize_url

  print "verifier\n"
  STDOUT.flush
  verifier = STDIN.gets.chop.strip

  access_token = request_token.get_access_token(:oauth_verifier => verifier)


  puts(["token: ", access_token.token].join)
  puts(["secret: ", access_token.secret].join)

  settings["twitter"]["token"] = access_token.token
  settings["twitter"]["secret"] = access_token.secret

  save_settings(settings)
end

def get_client
  settings = load_settings
  client = Twitter::REST::Client.new do |config|
    config.consumer_key  = settings["twitter"]["consumer_key"]
    config.consumer_secret  = settings["twitter"]["consumer_secret"]
    config.access_token = settings["twitter"]["token"]
    config.access_token_secret = settings["twitter"]["secret"]
  end
  return client
end


def set_timeline_data(timeline = {})
  unless timeline.attrs[:id].nil? || timeline.attrs[:user][:id].nil?
    sql = "select count(*) from timeline where id = '#{timeline.attrs[:id]}'"
    count = @connection.exec(sql)

    if count[0].to_hash["count"] == "0" 
      sql = "insert into timeline values ($1,$2,$3,$4,$5,$6,$7)"
      result = @connection.exec(sql, [timeline.attrs[:id] , timeline.attrs[:text] , timeline.attrs[:user][:id] , timeline.attrs[:user][:name] , timeline.attrs[:user][:screen_name] , DateTime.parse(timeline.attrs[:created_at]).to_s, timeline.attrs.to_json ] )
    end
  end
end

def set_user(user = {})
  unless user[:id].nil?
    sql = "select count(*) from users where id = '#{user[:id]}'"
    count = @connection.exec(sql)

    if count[0].to_hash["count"] == "0"
      sql = "insert into users values ($1,$2,$3,$4,$5,$6,$7,$8,$9)"
      result = @connection.exec(sql,
                                [ user[:id],
                                  user[:name],
                                  user[:screen_name],
                                  user[:location],
                                  user[:description],
                                  user[:url],
                                  user[:lang],
                                  user[:profile_image_url],
                                  user[:created_at]])
        
    end
  end
end

def set_user_log(user = {})
  unless user[:id].nil?
      sql = "insert into user_logs (user_id,
      name,
      screen_name,
      location,
      description,
      url,
      lang,
      profile_image_url,
      followers_count,
      friends_count,
      listed_count,
      created_at)
      values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)"
      result = @connection.exec(sql,
                                [ user[:user_id],
                                  user[:name],
                                  user[:screen_name],
                                  user[:location],
                                  user[:description],
                                  user[:url],
                                  user[:lang],
                                  user[:profile_image_url],
                                  user[:followers_count],
                                  user[:friends_count],
                                  user[:listed_count],
                                  DateTime.now])
  end
end

def set_timeline_log(timeline = {})
  unless timeline.nil?
    sql = "insert into tweet_logs (tweet_id,
    retweet_count,
    favorite_count,
    created_at)
    values ($1,$2,$3,$4)"
    result = @connection.exec(sql,
                              [ timeline.attrs[:id],
                                timeline.attrs[:retweet_count],
                                timeline.attrs[:favorite_count],
                                DateTime.now])
  end
end

def pg_connect_option
  settings = load_settings
  options = [:host,:user,:dbname,:port]
  pg_connect_option = {}
  options.each do |key|
    pg_connect_option[key] = settings["postgresql"][key.to_s] if settings["postgresql"][key.to_s] != ""
  end
  p pg_connect_option
  pg_connect_option
end

def pg_exec_block
  begin
    @connection = PG::connect(pg_connect_option)
    # p @connection.host
    # p @connection.user
    # p @connection.port
    # p @connection.pass
    # p @connection.db
    yield
  rescue => e
    puts e.message
  ensure
    @connection.finish if ! @connection.nil?
  end
end

def backup_tl
  settings = load_settings
  @client = get_client

  pg_exec_block do
    @client.home_timeline(:count => "200").each do |line|
      set_timeline_data(line)
      set_timeline_log(line)
      set_user(line.attrs[:user])
      set_user_log(line.attrs[:user])
    end
  end
end
