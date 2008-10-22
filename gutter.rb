Shoes.setup do
  gem 'twitter'
end
require 'twitter'
require 'yaml'

class Gutter
  attr_accessor :user
  attr_accessor :password

  def initialize
    conf = YAML::load(File.open(File.join("#{ENV['HOME'] || ENV['USERPROFILE']}",'.gutter.yml')))
    @user = conf["gutter"]["login"]
    @password = conf["gutter"]["password"]
  rescue
    @user, @password = nil, nil
  end

  def save
    YAML::dump({'gutter' => {'login' => user, 'password' => password}}, File.open(File.join("#{ENV['HOME'] || ENV['USERPROFILE']}",'.gutter.yml'), 'w'))
  rescue
    puts "Can't open preferences file"
  end
end

module GutterUI
  def insert_links(str)
    str.split.inject([]) do |a,e|
      result = (e =~ %r[https?://\S*]) ? link(e, :click => e) : e
      a << result
      a << ' '
    end
  end

  def reply(status)
    @tweet_text.text = "@#{status.user.screen_name} "
  end

  def draw_timeline
    @twit.timeline(:friends).each do |status|
      tweet = flow :margin => [5,5,20,5] do
        background '#202020', :curve => 8
        border dimgray, :curve => 8
        stack :width => 50, :margin => [4,4,2,4] do
          image status.user.profile_image_url
          click { reply(status) }
        end
        flow :width => 500 - width do
          inscription(strong("#{status.user.name}: ", :stroke => darkorange), insert_links(status.text), ' ', link('reply', :click => lambda {reply(status)}), :margin_left => 20, :stroke => white)
        end
      end # end tweet
    end # end twit
  end
end

Shoes.app(:scroll => false) do
  extend GutterUI 
  background black
  stroke white
  gtter = Gutter.new
  while gtter.user.blank? || gtter.password.blank?
    gtter.user = ask('Please enter your Twitter Username:')
    gtter.password = ask('Please enter your Twitter Password:')
  end
  gtter.save
  @twit = Twitter::Base.new(gtter.user, gtter.password)
  @timeline = stack :height => height - 38, :width => width, :scroll => true do
    para "loading"
  end
  flow do 
    background '#202020'
    border dimgray
    @tweet_text = edit_line("", :width => width - 250) do |e| 
      @counter.text =  140 - (e.text.size || 0)
    end
    button "blag" do
      @twit.post(@tweet_text.text)
      @tweet_text.text = ''
    end
    para link('refresh', :click => lambda { @timeline.clear { draw_timeline } })
    para " | "
    @counter = strong("0")
    para @counter, :stroke => white
  end
  @timeline.clear { draw_timeline }
  timer(60*6) do
    @timeline.clear { draw_timeline }
  end
end
