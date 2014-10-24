# encoding: utf-8
require 'bundler'
Bundler.require


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db/development.db")
DataMapper::Property::String.length 256

class Magazine
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  has n, :issues
end

class Issue
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :cover_url, String
  property :cover_thumb_url, String
  property :published_at, Date
  belongs_to :magazine
  has n, :productions
end

class Production
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  belongs_to :issue
  belongs_to :author
end

class Author
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :name_ruby, String, :required => true
  has n, :productions
end

class User
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Decimal, :required => true
  property :screen_name, String, :required => true
  property :token, String, :required => true
  property :secret, String, :required => true
end

DataMapper.finalize

def database_upgrade!
  Magazine.auto_upgrade!
  Issue.auto_upgrade!
  Production.auto_upgrade!
  Author.auto_upgrade!
  User.auto_upgrade!
end

