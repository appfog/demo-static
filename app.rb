require 'sinatra'
require 'json'
require 'mongo_mapper'

set :protection, except: :ip_spoofing

mongo_service = JSON.parse(ENV['VCAP_SERVICES'])['mongodb-1.8'].first
mongo_host      = mongo_service['credentials']['hostname'] rescue 'localhost'
mongo_port      = mongo_service['credentials']['port'] rescue 27017
mongo_database  = mongo_service['credentials']['db'] rescue 'tutorial_db'
mongo_username  = mongo_service['credentials']['username'] rescue ''
mongo_password  = mongo_service['credentials']['password'] rescue ''
MongoMapper.connection = Mongo::Connection.new(mongo_host, mongo_port)
MongoMapper.database = mongo_database
MongoMapper.database.authenticate(mongo_username, mongo_password)

class Statistic
  include MongoMapper::Document

  key :name, String
  key :count, Integer
end

get '/:name' do
  stat = Statistic.find_by_name(params[:name])
  if stat.nil?
    halt 404
  end

  status 200
  stat.to_json
end

post '/inc/:name' do
  stat = Statistic.find_by_name(params[:name])
  if stat.nil?
    stat = Statistic.create(name: params[:name], count: 0)
  end

  stat.increment(count: 1)
  stat.reload.to_json
end
