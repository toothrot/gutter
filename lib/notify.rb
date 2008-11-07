module Notify
  def self.extended(base)
    base.instance_eval do
      @which = `which /usr/local/bin/growlnotify || which growlnotify || which notify-send`.chomp!
      if @which.blank?
        info 'no notify-send or growlnotify!'
      else
        info "notify enabled through #{@which}"
      end
    end
  end

  def notify(command, statuses)
    @olds ||= []
    news = statuses.reject { |i| @olds.include?(i) }
    @olds = statuses
    news[0..3].each do |status|
      command =~ /growl/ ? growl(status.user.name, status.text) : libnotify(status.user.name, status.text)
    end
  end

  def growl(user,status)
    `#{@which} -t "#{user}" -m "#{status.gsub('"','\"')}"`
  end

  def libnotify(user,status)
    `#{@which} "#{user}" "#{status.gsub('"','\"')}"`
  end
end
