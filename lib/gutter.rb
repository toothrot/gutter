class Gutter
  attr_accessor :user, :password

  def initialize
    @user = Gutter.login
    @password = Gutter.password
  end

  def destroy
    save
  end

  def self.method_missing m,*args
    Gutter.load_conf
    return @conf["gutter"][m.to_s] if @conf["gutter"]
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
    YAML::dump(@conf.to_yaml, File.open(@filename, 'w'))
  rescue
    puts "Can't open preferences file"
  end

  def self.get_conf
    @filename = File.join("#{ENV['HOME'] || ENV['USERPROFILE']}",'.gutter.yml')
    @conf = YAML::load_file(@filename)
  end

end
