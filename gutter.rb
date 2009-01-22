Shoes.setup do
  gem 'httparty'
  gem 'htmlentities'
end
require 'httparty'
require 'yaml'
require 'htmlentities'
require 'lib/gutter'
require 'lib/gutter_ui'
require 'lib/post'
require 'lib/accounts/twitter'
require 'lib/notify'
require 'lib/tiny_url_support'

# this should go away
cache = File.join(LIB_DIR, "+data")
File.delete(cache) if File.exists?(cache)

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
    @twit = TwitterAccount.new(
      :user => @gtter.user, :password => @gtter.password)
  end

  get_login = lambda do
    @login = stack :width => 250, :left => width/2 - 250/2, :top => height/2 - 200 do
      background gray(0.2), :curve => 10
      border gray(0.6), :curve => 10
      failed = para('', :stroke => red).hide
      logo = image "http://assets1.twitter.com/images/twitter_logo_s.png"
      stack :margin => [20]*4 do
        user_input = edit_line
        password_input = edit_line(:secret => true)
        button "Log In", :click => lambda {
          @gtter.user = user_input.text
          @gtter.password = password_input.text
          begin
            get_auth.call
            @gtter.save
            ui_start
          rescue => e
            info e
            failed.text = "#{failed.text} Failed ..."
            failed.show
          end
        }
      end
    end
  end

  get_login.call
  begin
    get_auth.call
    ui_start
  rescue => e
    info e
    @login.show
  end
end

