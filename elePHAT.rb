class FailureApp
  def call(env)
    uri = env['REQUEST_URI']
    puts "failure #{env['REQUEST_METHOD']} #{uri}"
  end
end

class Logic < Sinatra::Base
#Authentication (warden)
  enable :sessions
  use Rack::Session::Cookie, :secret => "secre1_messaga_lol"

  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = FailureApp.new
  end

  Warden::Manager.serialize_into_session do |user|
    user.id
  end

  Warden::Manager.serialize_from_session do |id|
    User.get(id)
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['username'] || params['password']
    end

    def authenticate!
      puts '[INFO] password strategy authenticate'
      u = User.authenticate(params['username'], Digest::MD5.hexdigest(params['password']))
      u.nil? ? fail!('Could not login in') : success!(u)
    end
  end

  before  do
    redirect '/login' unless env['warden'].user || ['/login', '/signup'].include?(request.env['REQUEST_URI'])
  end

  get '/logout' do
    env['warden'].logout
    redirect '/'
  end

  get '/login' do
    erb :login, layout: false
  end

  post  '/login' do
    if env['warden'].authenticate
      redirect '/'
    else
      @error = true
      erb :login, layout: false
    end
  end

  get '/signup' do
    erb :signup, layout: false
  end

 post '/signup' do
    @page = 'create'
    @answer = register(params[:username], params[:password])

    if @answer[0]
      env['warden'].authenticate
      redirect '/'
    else
      @username_errors = @answer[1].on(:username)
      @password_errors = @answer[1].on(:password)
      erb :signup, layout: false
    end
  end

  get '/' do
      erb :main
  end

  get '/create' do
    @page = 'create'
    @title_errors = false
    @body_errors = false
    erb :new_post_form
  end

  post '/create' do
    @page = 'create'
    @answer = write_post(params[:title], params[:body], params[:tags].downcase)

    if @answer[0]
      session[:post_title] = ""
      session[:post_body] = ""
      session[:post_tags] = ""
      redirect "/post/#{@answer[1]}"
    else
      session[:post_title] = params[:title]
      session[:post_tags] = params[:tags]
      session[:post_body] = params[:body]
      @title_errors = @answer[1].on(:title)
      @body_errors = @answer[1].on(:body)
      erb :new_post_form
    end
  end

  get '/posts' do
    @page = 'posts'
    @posts = Post.all(visible: true, user: env['warden'].user.username)
    erb :show_posts
  end

  get '/post/:id' do |id|
    @post = Post.first(id: id, user: env['warden'].user.username)
    erb :view_post
  end

  post '/post/delete' do
  	post = Post.first(title: params[:hidden_title], user: env['warden'].user.username)
  	post.update(visible: false)
  	redirect '/posts'
  end

  get '/tag/:tag_value' do |tag|  
    @page = 'posts'
    @posts = Post.tagged_with(tag).all(visible: true, user: env['warden'].user.username)
    erb :show_posts
  end

  post '/post/:id/edit' do |id|
  	@post = Post.first(id: id, user: env['warden'].user.username)
  	@answer = update(params[:id], params[:title], params[:body], params[:tags])
    if @answer[0] then
  	  redirect "/post/#{id}"
    else
      @title_errors = @answer[1].on(:title)
      @body_errors = @answer[1].on(:body)
      erb :view_post
    end
  end
end