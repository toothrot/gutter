Shoes.setup do
  gem 'twitter'
end
require 'twitter'
require 'yaml'

#this should go away
cache = File.join(LIB_DIR, "+data")
File.delete(cache) if File.exists?(cache)

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
    str.gsub!(%r[&quot;], '"')
    str.gsub!(%r[&#8217;], "'")
    str.gsub!(%r[&amp;], '&')
    str.split.inject([]) do |a,e|
      result = if (e =~ %r[https?://\S*]) 
        link(e, :click => e)
      elsif (e =~ %r[@\w])
        link(e, :underline => 'none')
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

  def status_background(status)
    if status.text =~ %r[@#{@user}]
      background '#303030', :curve => 10
      border gray, :curve => 10
    else 
      background '#202020', :curve => 10
      border (status.user.screen_name == @user) ? darkslateblue : '#303030', :curve => 10
    end
  end

  def status_image(status)
    stack :width => 50, :margin => [6,6,2,6] do
      image status.user.profile_image_url if status.user
      click { reply(status) }
    end
  end

  def status_text(status)
    stack :width => -80 do
      flow do
        para(strong(status.user.name, :stroke => darkorange), :margin => [10,5,5,0])
        inscription(Time.parse(status.created_at).strftime("at %X"), :stroke => gray, :margin => [10,8,0,0])
      end
      inscription(insert_links(status.text), ' ', :margin => [10,0,0,6], :stroke => white)
    end
  end

  def status_controls(status)
    control = stack :width => 29, :margin => [5,2,2,5] do
      stack :width => '20', :margin => [2,2,0,0] do
        image('http://toothrot.nfshost.com/gutter/icons/arrow_undo.png', :click => lambda { reply(status) })
        image('http://toothrot.nfshost.com/gutter/icons/page_edit.png', :click => lambda { ask ("Direct Message #{status.user.screen_name}")})
      end
    end
  end

  def draw_timeline
    active_controls = nil
    @twit.timeline(:friends).each do |status|
      tweet = flow :margin => [5,4,20,4] do
        status_background(status)
        status_image(status)
        status_text(status)
        control = status_controls(status)
        control.hide

        hover { control.show }
        leave { control.hide }
      end # end tweet
    end # end twit
  end
end

Shoes.app :title => 'gutter', :width => 450 do
  extend GutterUI 
  background black
  stroke white
  gtter = Gutter.new
  while gtter.user.blank? || gtter.password.blank?
    gtter.user = ask('Please enter your Twitter Username:')
    gtter.password = ask('Please enter your Twitter Password:', :secret => true)
  end
  gtter.save
  @user = gtter.user
  @twit = Twitter::Base.new(gtter.user, gtter.password)
  stack do
    flow do 
      background '#202020'
      border dimgray
      flow :margin => [5,5,5,0] do
        @tweet_text = edit_line("", :width => width - 140) do |e| 
          @counter.text =  140 - (e.text.size || 0)
        end
        @blag = stack :width => 40, :margin_left => 4, :margin_right => 4 do
          background '#303030'
          border dimgray
          inscription "blag", :margin => [4]*4, :stroke => white
          hover { @blag.border gray }
          leave { @blag.border dimgray }
          click do
            @blag.border white
            @twit.post(@tweet_text.text)
            @tweet_text.text = ''
            timer(5) { @timeline.clear { draw_timeline } }
          end
          release { @blag.border gray }
        end
        image('http://toothrot.nfshost.com/gutter/icons/arrow_refresh.png', :click => lambda { @timeline.clear { draw_timeline } }, :margin => [5,5,5,5] )
        para "| ", :stroke => gray
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

