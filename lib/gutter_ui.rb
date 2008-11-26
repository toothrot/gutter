module GutterUI
  def insert_links(str)
    str.gsub!(%r[&quot;], '"')
    str.gsub!(%r[&#8217;], "'")
    str.gsub!(%r[&amp;], '&')
    str.split.inject([]) do |a,e|
      result = if (e =~ %r[https?://\S*]) 
        link(e, :click => e)
      elsif (e =~ %r[@\w])
        link_to_profile(e)
      else
        e
      end
      a << result
      a << ' '
    end
  end
  
  def link_to_profile(reply_to_user)
    user_id = reply_to_user.delete("@:")
    link(reply_to_user, :underline => 'none').click("http://twitter.com/#{user_id}")
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
    end
  end

  def status_time(status)
    Time.parse(status.created_at).strftime("at %I:%M%p").downcase.chop
  end

  def status_text(status)
    stack :width => -80 do
      flow do
        para(strong(status.user.name, :stroke => darkorange), :margin => [10,5,5,0])
        inscription(status_time(status), :stroke => gray, :margin => [10,8,0,0])
      end
      inscription(insert_links(status.text), ' ', :margin => [10,0,0,6], :stroke => white, :leading => 0)
    end
  end

  def status_controls(status)
    stack :width => 29, :margin => [7,5,5,5] do
      image('http://toothrot.nfshost.com/gutter/icons/arrow_undo.png', 
        :click => lambda { reply(status) })
    end
  end

  def draw_timeline
    statuses = @twit.timeline(:friends)
    notify(@which,statuses)
    statuses.each do |status|
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

  def ui_start
    @login.hide if @login

    send_tweet = lambda do
      @twit.post(tinify_urls_in_text(@tweet_text.text), :source => 'gutter')
      @tweet_text.text = ''
      timer(5) { @timeline.clear { draw_timeline } }
    end

    @timeline = stack do
      displace(0, -8)
      para "loading"
    end

    flow :attach => Window, :top => 0, :left => 0, :height => 40, :width => width - gutter do # - header
      background gray(0.2, 0.8)
      border dimgray
      flow :margin => [5,5,5,0] do
        @tweet_text = edit_line("", :width => width - 140 - gutter) do |e| 
          @counter.text =  140 - (e.text.size || 0)
        end
        @blag = stack :width => 40, :margin_left => 4, :margin_right => 4 do
          dark = rect :width => 30, :height => 14, :curve => 4, :top => 4, :fill => gray(0.3), :stroke => gray(0.6)
          light = rect :width => 30, :height => 14, :curve => 4, :top => 4, :fill => gray(0.3), :stroke => gray(0.9)
          light.hide
          inscription 'blag', :font => '9', :stroke => gray(0.8)
          dark.click { send_tweet.call }
          dark.hover { light.show }
          dark.leave { light.hide }
        end
        image('http://toothrot.nfshost.com/gutter/icons/arrow_refresh.png', :click => lambda { @timeline.clear { draw_timeline } }, :margin => [5,5,5,5] )
        para "| ", :stroke => gray
        @counter = strong("140")
        para @counter, :stroke => white
      end
    end # - header

    keypress do |k|
      send_tweet.call if (k == :enter) || (k == "\n")
      @timeline.scroll_top += 3 if k == :up
      @timeline.scroll_top -= 3 if k == :down
    end


    @timeline.clear { draw_timeline }
    every(60*6) do
      @timeline.clear { draw_timeline }
    end

    every(1) do
      @timeline.style(:height => height - 45)
    end
  end
end
