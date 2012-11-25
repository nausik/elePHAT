#Post model
class Post

  include DataMapper::Resource

  property :id,            Serial
  property :title,         String
  property :body,          Text     
  property :visible,       Boolean
  property :creation_date, DateTime
  property :user,          String

  validates_uniqueness_of :title
  validates_presence_of :title, :body
  has_tags
end
