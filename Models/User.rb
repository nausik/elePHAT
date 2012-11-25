#User model
class User
  include DataMapper::Resource

  property :id,            Serial
  property :username,      String
  property :password,      String
  property :creation_date, DateTime

  validates_uniqueness_of :username
  validates_presence_of :username, :password

  def self.authenticate(username, password)
    user = first(:username => username)
    if user
      if user.password != password
        user = nil
      end    
      user
    end
  end
end
