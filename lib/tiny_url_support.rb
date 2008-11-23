require 'uri'
require 'net/http'

module TinyURLSupport
  def tinify_urls_in_text(text)
    tinified_text = text
    urls = URI.extract(text, ["http", "https"])
    urls.each { |url| tinified_text.gsub!(url, tiny_url_for(url)) }
    tinified_text
  end
  
private
  def tiny_url_for(full_url)
    return full_url if already_tiny_url?(full_url)
    Net::HTTP.get URI.parse("http://tinyurl.com//api-create.php?url=#{full_url}")
  end
  
  def already_tiny_url?(url)
    url =~ /tinyurl.com/
  end
end