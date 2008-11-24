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
    Time.parse(status.created_at).strftime("at %I:%M%p").downcase
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
      image('http://toothrot.nfshost.com/gutter/icons/arrow_undo.png', :click => lambda { reply(status); app.slot.scroll_top = 0 })
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
end
