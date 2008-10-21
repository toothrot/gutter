Shoes.setup do
  gem 'twitter'
end
require 'twitter'
require 'yaml'

class Gutter
  attr_accessor :user
  attr_accessor :password

  def initialize
    conf = YAML::load(File.open('gutter.yml'))
    @user = conf["gutter"]["login"]
    @password = conf["gutter"]["password"]
  end

end

module GutterUI
  def draw_timeline
    @timeline = stack :height => height - 35, :scroll => true do
      @twit.timeline(:friends).each do |status|
        tweet = flow :margin => [5,5,5,5] do
          background white
          border(black, :strokewidth => 2)
          stack :width => 50, :margin => [2,2,2,2] do
            image status.user.profile_image_url
          end
          stack :width => 500 - width do
            inscription(strong("#{status.user.name}: "), status.text, :margin_left => 20)
          end
        end
      end # end timeline
    end
  end
end

Shoes.app do
  extend GutterUI 
  gtter = Gutter.new
  @twit = Twitter::Base.new(gtter.user, gtter.password)
  draw_timeline
  flow do 
    tweet_text = edit_line "tweet", :width => width - 250
    button "blag" do
      @twit.post(tweet_text.text)
    end
    button "refresh" do
      @timeline.clear { draw_timeline }
    end
  end
end
