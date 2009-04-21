require 'hpricot'
module GutterUI
  include TimelineUI
  include SettingsUI

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
            :click => lambda { show_settings }, :margin => [5,5,5,5] )
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

  def reload!
    @config = GutterConfig.get_conf
    get_auth
    ui_start
  end

  def get_auth
    @user = @config.user
    @twit = TwitterAccount.new(
      :user => @config.user, :password => @config.password)
  end
end
