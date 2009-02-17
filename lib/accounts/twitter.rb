class TwitterAccount
  include HTTParty
  format :json
  base_uri 'twitter.com'
  attr_accessor :username, :password, :authorized

  def initialize(opts)
    @auth = {:username => opts[:user], :password => opts[:password]}

    begin
    auth_response = self.class.get(
      'http://twitter.com/account/verify_credentials.json', 
      :basic_auth => @auth
    )
    @authorized = auth_response["error"].blank?
    rescue
      @authorized = false
    end
  end

  def post(text)
    options = {
        :query => {:status => text, :source => 'gutter'}, :basic_auth => @auth}
    self.class.post('/statuses/update.json', options)
  end

  def timeline(which = :friends, options = {})
    options.merge!({:basic_auth => @auth})
    page = options[:page] || 1
    twits = self.class.get("/statuses/#{which}_timeline.json?page=#{page}", options)
    twits.inject([]) { |memo, twit| memo << Post.new(twit) }
  end

  def friends
    options = {:basic_auth => @auth}
    friends = self.class.get("/statuses/friends.json", options)
    friends.inject([]) { |memo, friend| memo << User.new(friend) }
  end
end
