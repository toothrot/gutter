require 'hpricot'
module GutterUI
  def insert_links(str)
    decoded = HTMLEntities.new.decode(str)

    decoded.split.inject([]) do |a,e|
      result = if(e =~ %r[https?://twitpic.com.*])
        link(e) { do_twitpic(e.delete(',')) }
      elsif(e =~ %r[https?://\S*])
        link(e, :click => e)
      elsif(e =~ %r[@\w])
        link_to_profile(e)
      else
        e
      end
      a << result
      a << ' '
    end
  end

  def do_twitpic(url)
    window(:title => 'twitpic') do
      background black
      @loading = title 'Loading...', :stroke => white
      download url do |dump|
        image("http://twitpic.com/#{Hpricot(dump.response.body).at('#pic').get_attribute('src')}")
        @loading.remove
      end
    end
  end

  def link_to_profile(reply_to_user)
    user_id = reply_to_user.delete("@:")
    link(reply_to_user, :underline => 'none').click("http://twitter.com/#{user_id}")
  end

  def reply(status)
    @tweet_text.text = "@#{status.user.screen_name} "
  end

  def gray_button(text, click_proc)
    stack :width => 40, :margin_left => 4, :margin_right => 4, :scroll => false, :height => 15 do
      dark = rect(:width => 30, :height => 14, :curve => 4,
        :fill => gray(0.3), :stroke => gray(0.6))
      light = rect(:width => 30, :height => 14, :curve => 4,
        :fill => gray(0.3), :stroke => gray(0.9))
      light.hide
      inscription text, :font => '9', :stroke => gray(0.8), :margin_top => 0
      dark.click { click_proc.call }
      dark.hover { light.show }
      dark.leave { light.hide }
    end
  end

  def status_background(status)
    if status.text =~ %r[@#{@user}]
      background '#303030', :curve => 10
      border gray, :curve => 10, :strokewidth => 2
    else 
      background '#202020', :curve => 10
      border (status.user.screen_name == @user) ? darkslateblue : '#303030', :curve => 10, :strokewidth => 2
    end
  end

  def status_image(status)
    stack :width => 50, :margin => [6,6,2,6] do
      image status.user.image_url if status.user
    end
  end

  def status_time(status)
    Time.parse(status.created_at).strftime("at %I:%M%p").downcase.chop
  end

  def status_text(status)
    stack :width => -77 do
      flow do
        para(status.user.name, :stroke => darkorange, :margin => [10,5,5,0], :font => 'Coolvetica')
        inscription(status_time(status), :stroke => gray, :margin => [10,8,0,0])
      end
      inscription(insert_links(status.text), ' ', :margin => [10,0,0,6], :stroke => white, :leading => 0)
    end
  end

  def status_controls(status)
    stack :width => 22, :margin => [7,5,7,5] do
      image('http://toothrot.nfshost.com/gutter/icons/arrow_undo.png', 
        :click => lambda { reply(status) })
    end
  end

  def draw_timeline
    statuses = @twit.timeline(:friends)
    notify(@which,statuses)
    statuses.each do |status|
      unless @gtter.ignores.include? status.user.name
        tweet = flow :margin => [5,4,gutter + 5,4] do
          status_background(status)
          status_image(status)
          status_text(status)
          control = status_controls(status)
        end # end tweet
      end
    end # end twit
  end

  def get_login
    @content.clear do
      @login = stack :width => 250, :left => width/2 - 250/2, :top => height/2 - 200 do
        background gray(0.2), :curve => 10
        border gray(0.6), :curve => 10
        failed = para('', :stroke => red).hide
        logo = image "http://assets1.twitter.com/images/twitter_logo_s.png"
        stack :margin => [20]*4 do
          user_input = edit_line(:text => @gtter.user)
          password_input = edit_line(:secret => true, :text => @gtter.password)
          button "Log In" do
            @gtter.user = user_input.text
            @gtter.password = password_input.text
            @gtter.save
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
    @user = @gtter.user
    @twit = TwitterAccount.new(
      :user => @gtter.user, :password => @gtter.password)
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
            list_box(:items => @twit.friends.map(&:name), :margin_left => 10) do |friend_name|
              @gtter.ignores << friend_name.text
              @ignores.text = @gtter.ignores.join(", ")
            end
            button("clear") { @gtter.ignores = []; @ignores.text = "" }
          end
          @ignores = para(@gtter.ignores.join(", "), :stroke => white, :margin_left => 10)
          button("Go Back") { @gtter.save; ui_start }
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
