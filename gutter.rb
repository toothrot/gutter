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

Shoes.app do
  gtter = Gutter.new
  twit = Twitter::Base.new(gtter.user, gtter.password)
  stack :height => 400, :scroll => true do
    twit.timeline(:friends).each do |status|
      stack :margin => [5,5,5,5] do
        rect(:width => width, :height => height, :curve => 3, :fill => white)
        flow do
          image status.user.profile_image_url
          para(strong("#{status.user.name}: "), status.text, :margin_left => 50)
        end
      end
    end
  end
end
