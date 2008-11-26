Shoes.setup do
  gem 'twitter'
end
require 'twitter'
require 'yaml'
require 'lib/gutter'
require 'lib/gutter_ui'
require 'lib/notify'
require 'lib/tiny_url_support'

# this should go away
cache = File.join(LIB_DIR, "+data")
File.delete(cache) if File.exists?(cache)

class Twitter::Status
  def ==(other)
    self.id == other.id
  end
end

Shoes.app :title => 'Gutter', :width => 450, :scroll => false do
  extend GutterUI 
  extend Notify
  extend TinyURLSupport

  app.slot.scroll(false)

  background black
  stroke white

  ## -- setup
  @gtter = Gutter.new

  get_auth = lambda do
    @user = @gtter.user
    @twit = Twitter::Base.new(@gtter.user, @gtter.password)
  end

  get_login = lambda do
    @login = stack :width => 250, :left => width/2 - 250/2, :top => height/2 - 200 do
      background gray(0.2)
      border gray(0.6)
      stack :margin => [20]*4 do
        user_input = edit_line
        password_input = edit_line(:secret => true)
        button "Log In", :click => lambda {
          @gtter.user = user_input.text
          @gtter.password = password_input.text
          if get_auth.call
            @gtter.save
            ui_start
          end
        }
      end
    end
  end

  get_login.call
  if (!@gtter.user.blank? && !@gtter.password.blank?)
    get_auth.call
    ui_start
  end
end

