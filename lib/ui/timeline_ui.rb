module TimelineUI
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

  def link_to_profile(reply_to_user)
    user_id = reply_to_user.delete("@:")
    link(reply_to_user, :underline => 'none').click("http://twitter.com/#{user_id}")
  end

  def reply(status)
    @tweet_text.text = "@#{status.user.screen_name} "
  end

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

  def status_background(status)
    if status.text =~ %r[@#{@user}]
      background '#303030', :curve => 10
      border gray, :curve => 10, :strokewidth => 2
    else 
      background '#202020', :curve => 10
      border '#303030', :curve => 10, :strokewidth => 2
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
        para(status.user.name, :stroke => "#999", :margin => [10,5,5,0], :font => 'Coolvetica')
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

  def draw_timeline(page = 1)
    statuses = @twit.timeline(:friends, :page => page)
    notify(@which,statuses)
    statuses.each do |status|
      unless @config.ignores.include? status.user.name
        tweet = flow :margin => [5,2,gutter + 5,2] do
          status_background(status)
          status_image(status)
          status_text(status)
          control = status_controls(status)
        end # end tweet
      end
    end # end twit
    @more = flow :margin => [5,4,gutter+5,4] do
      background @config.status_background, :curve => 10
      para(link('load more', :click => lambda {
          @more.hide;
          @timeline.append { draw_timeline(page+1) }
        }), :stroke => white, :align => 'center')
    end
  end

end
