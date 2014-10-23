require 'bundler'
require 'sinatra'
require 'slim'
require './model'

configure :production do
  DataMapper.setup(:default, ENV["DATABASE_URL"])
  database_upgrade!
end

configure :test, :development do
  DataMapper.setup(:default, "yaml:///tmp/lodb")
  database_upgrade!
end

configure :development do
  require 'sinatra/reloader'
end

configure do
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, "#{File.dirname(__FILE__)}/public"
  enable :run
end

get '/' do
  @magazines = Magazine.all
  slim :index
end

get '/magazine/:id' do
  @magazine = Magazine.get(params[:id])
  @issues = @magazine.issues
  @title = @magazine.name
  slim :magazine
end

post '/magazine/:id/add_issue' do
  magazine = Magazine.get(params[:id])
  Issue.create(
    :name => params[:name],
    :published_at => params[:published_at],
    :magazine => magazine)
  redirect "/magazine/#{magazine.id}", 302
end

get '/issue/:id' do
  @issue = Issue.get(params[:id])
  @productions = @issue.productions
  @authors = Author.all
  @title = "#{@issue.name} - #{@issue.magazine.name}"
  slim :issue
end

post '/issue/:id/add_production' do
  issue = Issue.get(params[:id])
  author = Author.get(params[:author_id])
  Production.create(
    :name => params[:name],
    :author => author,
    :issue => issue)
  redirect "/issue/#{issue.id}", 302
end

get '/author' do
  @authors = Author.all
  @title = "Author"
  slim :author_index
end

post '/author/add' do
  Author.create(
    :name => params[:name],
    :name_ruby => params[:name_ruby])
  redirect "/author", 302
end
