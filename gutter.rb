Shoes.setup do
  gem 'httparty'
  gem 'htmlentities'
end
require 'httparty'
require 'yaml'
require 'htmlentities'
require 'lib/config'
require 'lib/ui/timeline_ui'
require 'lib/ui/gutter_ui'
require 'lib/post'
require 'lib/accounts/twitter'
require 'lib/notify'
require 'lib/tiny_url_support'
font 'vendor/fonts/coolvetica.ttf'

# this should go away
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
  get_login
end

