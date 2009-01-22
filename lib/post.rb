class Post
  attr_accessor :user, :text, :created_at
  def initialize(params)
    @user = User.new(params['user'])
    @text = params['text']
    @created_at = params['created_at']
  end

  def ==(other)
    (self.text == other.text) && (self.user.name == other.user.name)
  end

  def <=>(other)
    self.created_at <=> other.created_at
  end
end

class User
  attr_accessor :name, :screen_name, :image_url
  def initialize(params)
    @name = params['name']
    @screen_name = params['screen_name']
    @image_url = params['profile_image_url']
  end
end
