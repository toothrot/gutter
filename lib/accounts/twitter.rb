class TwitterAccount
  include HTTParty
  format :json
  base_uri 'twitter.com'
  attr_accessor :username, :password

  def initialize(opts)
    @auth = {:username => opts[:user], :password => opts[:password]}
  end

  def post(text)
    options = { :query => {:status => text}, :basic_auth => @auth }
    self.class.post('/statuses/update.json', options)
  end

  def timeline(which = :friends, options = {})
    options.merge!({:basic_auth => @auth})
    twits = self.class.get("/statuses/#{which}_timeline.json", options)
    twits.inject([]) { |memo, twit| memo << Post.new(twit) }
  end
end
