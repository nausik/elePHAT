#Connect DataMapper to DB
DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__))}/elephat.sqlite")
DataMapper.finalize
DataMapper.auto_upgrade!

def write_post(title, body, tags)
 post = Post.new(
 	title:         title,
  	body:          body,
    visible:       true,
  	creation_date: DateTime.now,
  	user:          env['warden'].user.username)
  post.tag_list = tags
  result = post.save ? [true, post.id] : [false, post.errors]
end

def register(username, password)
password = Digest::MD5.hexdigest(password) unless password == ""
  user = User.new(
    username:         username,
    password:         password,
    creation_date:    DateTime.now)
  result = user.save ? [true, user] : [false, user.errors]
end

def update(id, title, body, tags)
  post = Post.get(id)
  post.update(title: title, body: body) ? [true, post.id] : [false, post.errors]
end