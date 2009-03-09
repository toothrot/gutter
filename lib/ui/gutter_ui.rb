require 'hpricot'
module GutterUI
  include TimelineUI

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
          end
        end
      end
    end
  end

  def get_auth
    @user = @config.user
    @twit = TwitterAccount.new(
      :user => @config.user, :password => @config.password)
  end

  def draw_settings
    @content.clear do
      stack(:margin => [4]*4) do
        background gray(0.2), :curve => 10
        border gray(0.6), :curve => 10
        tagline "Settings", :stroke => white
        get_login
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
          button("Go Back") { @config.save; ui_start }
        end
      end
    end
  end

  def ui_start
    @content.clear do
      background black
      stroke white

      send_tweet = lambda do
        @twit.post(tinify_urls_in_text(@tweet_text.text))
        @tweet_text.text = ''
        timer(5) { @timeline.clear { draw_timeline } }
      end

      @timeline = stack :margin_top => 50 do
        displace(0, -8)
        para "loading"
      end

      #header
      flow(:attach => Window, :top => 0, :left => 0, :height => 42, :margin_right => gutter) do
        background gray(0.2, 0.8)
        border dimgray
        flow :margin => [5,5,5,0] do

          # Input
          @tweet_text = edit_line("", :width => width - 140 - gutter) do |e| 
            @counter.text =  140 - (e.text.size || 0)
          end

          # blag/counter
          stack :width => 40 do
            @blag = gray_button('blag', send_tweet)
            @counter = strong("140")
            inscription @counter, :stroke => white, :margin => [8,0,0,0]
          end
          para "| ", :stroke => gray

          # controls
          image('http://toothrot.nfshost.com/gutter/icons/arrow_refresh.png', :click => lambda { @timeline.clear { draw_timeline } }, :margin => [5,5,5,5] )
          image('http://toothrot.nfshost.com/gutter/icons/cog.png', :click => lambda { @timeline.clear { draw_settings } }, :margin => [5,5,5,5] )
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
end
