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
    YAML::dump({'gutter' => {'login' => user, 'password' => password}}, 
      File.open(@filename, 'w'))
  rescue
    puts "Can't open preferences file"
  end
end
