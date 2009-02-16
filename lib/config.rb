class GutterConfig
  FILENAME = File.join("#{ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH']}",'.gutter.yml')
  attr_accessor :user, :password, :ignores

  def initialize
    @ignores = []
  end

  def save
    File.open(GutterConfig::FILENAME, 'w') do |out|
      YAML::dump(self, out)
    end
  end

  def self.get_conf
    YAML::load_file(GutterConfig::FILENAME)
   rescue
    nil
  end

  def status_background
    "#202020"
  end

end
