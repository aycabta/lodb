require 'bundler'
Bundler.require

class App < Sinatra::Base

  def initialize *args
    require './model'
    DataMapper.auto_upgrade!
    super
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  configure do
    set :root, File.dirname(__FILE__)
    set :static, true
    set :public_folder, "#{File.dirname(__FILE__)}/public"
    enable :run
    enable :sessions
    set :session_secret, ENV["SESSION_SECRET"]
    use Rack::Session::Cookie,
      :key => 'rack.session',
      :path => '/',
      :expire_after => 2592000,
      :secret => ENV["SESSION_SECRET"]
    use OmniAuth::Builder do
      provider :twitter, ENV["TWITTER_API_KEY"], ENV["TWITTER_API_SECRET"]
    end
  end

  get '/' do
    @magazines = Magazine.all
    slim :index
  end

  get '/magazine/:id' do
    @magazine = Magazine.get(params[:id])
    @issues = Issue.all(:magazine => @magazine, :order => [ :published_at.asc, :name.asc ])
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

  post '/issue/:id/set_cover_url' do
    issue = Issue.get(params[:id])
    if not params[:cover_url].nil?
      issue.update(:cover_url => params[:cover_url])
    end
    if not params[:cover_thumb_url].nil?
      issue.update(:cover_thumb_url => params[:cover_thumb_url])
    end
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

  get '/author/:id' do
    @author = Author.get(params[:id])
    @productions = @author.productions.select(&:issue)
    @title = "#{@author.name} (#{@author.name_ruby})"
    slim :author
  end

  get '/production/:id' do
    @production = Production.get(params[:id])
    @title = "#{@production.name}"
    slim :production
  end

  get "/auth/:provider/callback" do
    auth = request.env["omniauth.auth"]
    user = User.first(:user_id => auth[:uid].to_i)
    if not user.nil?
      user.update(
        :screen_name => auth[:info][:nickname],
        :token => auth[:credentials][:token],
        :secret => auth[:credentials][:secret])
    else
      user = User.create(
        :user_id => auth[:uid].to_i,
        :screen_name => auth[:info][:nickname],
        :token => auth[:credentials][:token],
        :secret => auth[:credentials][:secret])
    end
    session[:screen_name] = user.screen_name
    session[:logged_in] = true
    redirect "/", 302
  end

  before do
    uri = URI(request.url)
    if request.request_method == 'PUT' and not session[:logged_in]
      redirect "/", 302
    else
      @screen_name = session[:screen_name]
    end
  end

end
