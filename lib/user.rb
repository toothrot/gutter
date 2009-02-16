class User
  attr_accessor :name, :screen_name, :id, :image_url
  def initialize(attributes)
    @name = attributes["name"]
    @screen_name = attributes["screen_name"]
    @id = attributes["id"]
    @image_url = attributes['profile_image_url']
  end
end
