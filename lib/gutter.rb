class Gutter
  attr_accessor :user, :password

  def initialize
    @filename = File.join("#{ENV['HOME'] || ENV['USERPROFILE']}",'.gutter.yml')
    conf = YAML::load_file(@filename)
    @user = conf["gutter"]["login"]
    @password = conf["gutter"]["password"]
  rescue
    @user, @password = nil, nil
  end

  def save
    Gutter.save( @user, @password)
  end

  def self.load_conf
    @conf = nil unless defined?(@conf)
    Gutter.get_conf unless @conf
  end

  def self.save user,password
    Gutter.load_conf
    @conf["gutter"]["login"] = user
    @conf["gutter"]["password"] = password
    YAML::dump(@conf, File.open(@filename, 'w'))
  rescue
    puts "Can't open preferences file"
  end
end
