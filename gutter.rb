Shoes.setup do
  gem 'twitter'
end
require 'twitter'
require 'yaml'

class Gutter
  attr_accessor :user
  attr_accessor :password

  def initialize
    @filename = File.join("#{ENV['HOME'] || ENV['USERPROFILE']}",'.gutter.yml')
    conf = YAML::load_file(@filename)
    @user = conf["gutter"]["login"]
    @password = conf["gutter"]["password"]
  rescue
    @user, @password = nil, nil
  end

  def save
    YAML::dump({'gutter' => {'login' => user, 'password' => password}}, 
      File.open(@filename, 'w'))
  rescue
    puts "Can't open preferences file"
  end
end

module GutterUI
  def insert_links(str)
    str.split.inject([]) do |a,e|
      result = if (e =~ %r[https?://\S*]) 
        link(e, :click => e)
      elsif (e =~ %r[@\w])
        link(e, :underline => 'none')
      elsif (e =~ %r[&quot;])
        e.gsub(%r[&quot;], '"')
      else
        e
      end
      a << result
      a << ' '
    end
  end

  def reply(status)
    @tweet_text.text = "@#{status.user.screen_name} "
  end

  def draw_timeline
    @twit.timeline(:friends).each do |status|
      tweet = flow :margin => [5,4,20,4] do
        if status.text =~ %r[@#{@user}]
          background '#303030', :curve => 10
          border gray, :curve => 10
        else 
          background '#202020', :curve => 10
          border (status.user.screen_name == @user) ? darkslateblue : '#303030', :curve => 10
        end
        stack :width => 50, :margin => [6,6,2,6] do
          image status.user.profile_image_url if status.user
          click { reply(status) }
        end
        stack :width => -100 do
          flow do #header
            para(strong(status.user.name, :stroke => darkorange), :margin => [10,5,5,0])
            inscription(Time.parse(status.created_at).strftime("at %X"), :stroke => gray, :margin => [10,8,0,0])
          end
          inscription(insert_links(status.text), ' ', :margin => [10,0,0,6], :stroke => white)
        end
        flow :width => 50, :margin => [5,2,2,5] do
          background '#252525', :curve => 10
          border '#303030', :curve => 10
          stack :width => '50%', :margin => [2,2,0,0] do
            background '#303030', :curve => 8 
            border '#3a3a3a', :curve => 8
            hover { |r| r.border( gray, :curve => 8) }
            leave { |r| r.border('#3a3a3a', :curve => 8) }
            inscription('r', :margin => [6,0,6,4], :stroke => white)
            click { reply(status) }
          end
          stack :width => '50%', :margin => [2,2,0,0] do
            background '#303030', :curve => 8 
            border '#3a3a3a', :curve => 8
            hover { |r| r.border( gray, :curve => 8) }
            leave { |r| r.border('#3a3a3a', :curve => 8) }
            inscription('x', :margin => [6,0,6,4], :stroke => white)
          end
        end
      end # end tweet
    end # end twit
  end
end

Shoes.app :title => 'gutter' do
  extend GutterUI 
  background black
  stroke white
  gtter = Gutter.new
  while gtter.user.blank? || gtter.password.blank?
    gtter.user = ask('Please enter your Twitter Username:')
    gtter.password = ask('Please enter your Twitter Password:')
  end
  gtter.save
  @user = gtter.user
  @twit = Twitter::Base.new(gtter.user, gtter.password)
  stack do
    flow do 
      background '#202020'
      border dimgray
      flow :margin => [5,5,5,0] do
        @tweet_text = edit_line("", :width => width - 250) do |e| 
          @counter.text =  140 - (e.text.size || 0)
        end
        button "blag" do
          @twit.post(@tweet_text.text)
          @tweet_text.text = ''
          timer(10) { lambda { @timeline.clear { draw_timeline } } }
        end
        para link('refresh', :click => lambda { @timeline.clear { draw_timeline } })
        para " | "
        @counter = strong("140")
        para @counter, :stroke => white
      end
    end
    @timeline = stack :margin => [0,5,0,0] do
      para "loading"
    end
  end
  @timeline.clear { draw_timeline }
  every(60*6) do
    @timeline.clear { draw_timeline }
  end
end
