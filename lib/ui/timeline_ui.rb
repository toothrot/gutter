module TimelineUI
  def draw_timeline(page = 1)
    statuses = filter(@twit.timeline(:friends, :page => page))
    notify(@which,statuses)

    # main timeline
    statuses.each do |status|
      tweet = flow :margin_right => gutter do
        status_background(status)
        status_image(status)
        status_text(status)
        status_controls(status)
      end # end tweet
    end # end twit

    # "load more" link
    @more = flow :margin_right => gutter do
      background @config.colors[:background]
      para(
        link('load more', :click => lambda {
          @more.hide;
          @timeline.append { draw_timeline(page+1) }
        }), :align => 'center')
    end
  end

private
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
    user_id = reply_to_user.delete('@:!,.?')
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
      background @config.colors[:me][:background]
      border @config.colors[:me][:border], :strokewidth => 1
    else
      background @config.colors[:background]
      border @config.colors[:border], :strokewidth => 1
    end
  end

  def status_image(status)
    stack :width => 50, :margin => [6,6,2,6] do
      image(status.user.image_url, :width => 50) if status.user
    end
  end

  def status_time(status)
    Time.parse(status.created_at).strftime("at %I:%M%p").downcase.chop
  end

  def status_text(status)
    stack :width => -70 do
      flow do
        para(status.user.name,
          :stroke => @config.colors[:title], :margin => [10,5,5,0], :font => 'Coolvetica')
        inscription(status_time(status),
          :stroke => @config.colors[:title], :margin => [10,7,0,0])
      end
      inscription(insert_links(status.text),
        :stroke => @config.colors[:body], :margin => [10,0,0,2], :leading => 0).displace(0,-4)
    end
  end

  def status_controls(status)
    stack :width => 10, :margin_top => 5 do
      image('http://toothrot.nfshost.com/gutter/icons/arrow_undo.png',
        :click => lambda { reply(status) })
    end
  end

  def filter(twits)
    twits.reject do |t|
      @config.ignores.include?(t.user.name) ||
      @config.filters.detect { |f| t.text.match(%r[#{f}]) }
    end
  end

end
