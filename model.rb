require 'bundler'
require 'dm-core'
require 'dm-migrations'
require 'net/http'

class Magazine
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 256, :required => true
  has n, :issues
end

class Issue
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 256, :required => true
  property :cover_url, String, :length => 256
  property :cover_thumb_url, String, :length => 256
  property :published_at, Date
  belongs_to :magazine
  has n, :productions
end

class Production
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 256, :required => true
  belongs_to :issue
  belongs_to :author
end

class Author
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 256, :required => true
  property :name_ruby, String, :length => 256, :required => true
  has n, :productions
end

class Twitter
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Decimal, :required => true
  property :screen_name, String, :length => 256, :required => true
  property :token, String, :length => 256, :required => true
  property :secret, String, :length => 256, :required => true
end

DataMapper.finalize

def database_upgrade!
  Magazine.auto_upgrade!
  Issue.auto_upgrade!
  Production.auto_upgrade!
  Author.auto_upgrade!
  Twitter.auto_upgrade!
end

