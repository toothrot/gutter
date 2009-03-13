require 'hpricot'
module GutterUI
  include TimelineUI

  def ui_start
    @content.clear do
      background black
      stroke white

      send_tweet = lambda do
        @twit.post(tinify_urls_in_text(@tweet_text.text))
        @tweet_text.text = ''
        timer(5) { @timeline.clear { draw_timeline } }
      end

      @timeline = stack(:margin => [0,42,0,2]) do
        para "loading"
      end

      #header
      flow(:attach => Window, :top => 0, :left => 0, :height => 42, :margin_right => gutter) do
        background @config.colors[:background]
        border dimgray
        flow :margin => [5,5,5,0] do
          # Input
          @tweet_text = edit_line("", :width => -110) do |e| 
            @counter.text =  140 - (e.text.size || 0)
          end

          # blag/counter
          stack :width => 40 do
            @blag = gray_button('blag', send_tweet)
            @counter = strong("140")
            inscription @counter, :stroke => @config.colors[:body], :margin => [8,0,0,0]
          end
          para "| ", :stroke => gray

          # controls
          image('http://toothrot.nfshost.com/gutter/icons/arrow_refresh.png', 
            :click => lambda { @timeline.clear { draw_timeline } }, :margin => [5,5,5,5] )
          image('http://toothrot.nfshost.com/gutter/icons/cog.png', 
            :click => lambda { @timeline.clear { draw_settings } }, :margin => [5,5,5,5] )
        end
      end # - header

      keypress do |k|
        send_tweet.call if (k == :enter) || (k == "\n")
        @timeline.scroll_top -= 50 if k == :up
        @timeline.scroll_top += 50 if k == :down
      end

      @timeline.clear { draw_timeline }
      every(60*6) do
        @timeline.clear { draw_timeline }
      end
    end
  end

  def draw_settings
    @content.clear do
      stack(:margin => [4,4,4+gutter,4]) do
        background gray(0.2), :curve => 10
        border gray(0.6), :curve => 10
        tagline "Settings", :stroke => white
        get_login
        ignore_settings
        color_settings
        button("Go Back") { @config.save; ui_start }
      end
    end
  end

private
  def gray_button(text, click_proc)
    stack :width => 40, :margin_left => 4, :margin_right => 4, :scroll => false, :height => 15 do
      dark = rect(:width => 30, :height => 14, :curve => 4,
        :fill => gray(0.3), :stroke => gray(0.6))
      light = rect(:width => 30, :height => 14, :curve => 4,
        :fill => gray(0.3), :stroke => gray(0.9))
      light.hide
      inscription text, :font => 'Coolvetica 9', :stroke => gray(0.8), :margin_top => 0
      dark.click { click_proc.call }
      dark.hover { light.show }
      dark.leave { light.hide }
    end
  end

  def get_login
    @content.clear do
      @login = stack(:width => 290, :margin => [40,40,0,0]) do
        background gray(0.2), :curve => 10
        border gray(0.6), :curve => 10
        failed = para('', :stroke => red).hide
        logo = image "http://assets1.twitter.com/images/twitter_logo_s.png"
        stack :margin => [20]*4 do
          user_input = edit_line(:text => @config.user)
          password_input = edit_line(:secret => true, :text => @config.password)
          button "Log In" do
            @config.user = user_input.text
            @config.password = password_input.text
            @config.save
            if get_auth.authorized
              ui_start
            else
              failed.text = 'Failed...'
              failed.show
            end
          end # button
        end # stack
      end # stack
    end # clear
  end

  def ignore_settings
    stack(:margin => [8]*4) do
      para 'Ignore: ', :stroke => white
      flow do
        list_box(:items => @twit.friends.sort.map{|f| f.name}, :margin_left => 10) do |friend_name|
          @config.ignores << friend_name.text
          @ignores.text = @config.ignores.join(", ")
        end
        button("clear") { @config.ignores = []; @ignores.text = "" }
      end
      @ignores = para(@config.ignores.join(", "), :stroke => white, :margin_left => 10)
    end
  end

  def color_settings
    stack(:margin => [8]*4) do
      para 'Colors! ', :stroke => white
      demo = stack do
        background black
        demo_tweet
      end
      flow do
        [:background, :border, :title, :body].each do |part|
          button(part.to_s)do
            @config.colors[part] = ask_color(part.to_s.capitalize).to_s
            demo.clear { background black; demo_tweet }
          end
        end
        button("Reset Colors"){ @config.colors = nil; demo.clear {background black; demo_tweet} }
      end
    end
  end

  def demo_tweet
    flow :margin => [2]*4 do
      background @config.colors[:background], :curve => 10
      border @config.colors[:border], :curve => 10, :strokewidth => 2
      stack :width => 50, :margin => [6,6,2,6] do
        image "http://s3.amazonaws.com/twitter_production/profile_images/57493217/angry-bee-crop_normal.jpg"
      end
      stack :width => -77 do
        flow do
          para('Gutter', :stroke => @config.colors[:title], :margin => [10,5,5,0], :font => 'Coolvetica')
          inscription('at 10:55p', :stroke => @config.colors[:title], :margin => [10,7,0,0])
        end
        inscription('I like to go get lots of cheese and eat it publically.  This cheese does much, you know',
          :stroke => @config.colors[:body], :margin => [10,0,0,4], :leading => 0)
      end
    end
  end

  def get_auth
    @user = @config.user
    @twit = TwitterAccount.new(
      :user => @config.user, :password => @config.password)
  end
end
