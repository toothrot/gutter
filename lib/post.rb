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
