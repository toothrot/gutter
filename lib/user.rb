class User
  attr_accessor :name, :screen_name, :id
  def initialize(attributes)
    @name = attributes["name"]
    @screen_name = attributes["screen_name"]
    @id = attributes["id"]
  end
end
