Shoes.setup do
  gem 'httparty'
  gem 'htmlentities'
end
require 'httparty'
require 'yaml'
require 'htmlentities'
require 'lib/user'
require 'lib/post'
require 'lib/config'
require 'lib/ui/timeline_ui'
require 'lib/ui/gutter_ui'
require 'lib/ui/notify'
require 'lib/accounts/twitter'
require 'lib/helpers/tiny_url_support'
font 'vendor/fonts/coolvetica.ttf'

# this should go away, but caching is broken in Ubuntu 8.10
cache = File.join(LIB_DIR, "+data")
File.delete(cache) if File.exists?(cache)

Shoes.app :title => 'Gutter',:width => 400, :scroll => false do
  extend GutterUI 
  extend Notify
  extend TinyURLSupport

  app.slot.scroll(false)

  background black
  stroke white

  ## -- setup
  @config = GutterConfig.get_conf || GutterConfig.new 

  @content = stack
  if get_auth.authorized
    ui_start
  else
    get_login
  end
end
