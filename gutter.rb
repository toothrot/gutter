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
  def reply(status)
    @tweet_text.text = "@#{status.user.screen_name}: "
  end

  def draw_timeline
    @timeline = stack :height => height - 35, :width => width, :scroll => true do
      @twit.timeline(:friends).each do |status|
        tweet = flow :margin => [5,5,20,5] do
          background '#202020', :curve => 8
          border dimgray, :curve => 8
          stack :width => 50, :margin => [4,4,2,4] do
            image status.user.profile_image_url
            click { reply(status) }
          end
          flow :width => 500 - width do
            inscription(strong("#{status.user.name}: ", :stroke => darkorange), status.text, ' ', link('reply', :click => lambda {reply(status)}), :margin_left => 20, :stroke => white)
          end
        end # end tweet
      end # end twit
    end # end timeline
  end
end

Shoes.app do
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
  @timeline = flow :height => height - 35, :scroll => true do
    para "loading"
  end
  flow do 
    background '#202020'
    border dimgray
    @tweet_text = edit_line "", :width => width - 250
    button "blag" do
      @twit.post(tweet_text.text)
    end
    button "refresh" do
      @timeline.clear { draw_timeline }
    end
  end
  @timeline.clear { draw_timeline }
  timer(60*6) do
    @timeline.clear { draw_timeline }
  end
end
