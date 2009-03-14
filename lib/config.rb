class GutterConfig
  FILENAME = File.join("#{ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH']}",'.gutter.yml')
  attr_accessor :user, :password, :ignores, :filters, :colors

  def initialize
    colors
  end

  def ignores
    @ignores || []
  end

  def filters
    @filters || []
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

  def colors
    defaults = {
      :background => "#202020",
      :border => "#303030",
      :title => "#999",
      :body => "#FFF",
      :me => {
        :background => "#303030",
        :border => "#505050",
      } # me
    } # defaults
    @colors ||= defaults
  end
end
