require 'uri'
require 'hpricot'
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
    response = Net::HTTP.post_form(URI.parse('http://tinyurl.com/create.php'), {"url" => full_url})
    Hpricot(response.body).search("blockquote b")[1].inner_html
  end
end