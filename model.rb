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
  has n, :productions
end

DataMapper.finalize

def database_upgrade!
  Magazine.auto_upgrade!
  Issue.auto_upgrade!
  Production.auto_upgrade!
  Author.auto_upgrade!
end
