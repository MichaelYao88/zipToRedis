require "rubygems"
require "open-uri"
require "fileutils"
require "zip"
require "nokogiri"
require "redis"


def save_single_zip_to_redis(zip_url,redis)
  file = open(zip_url)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |entry|
      #looks like there are duplicates with slight differences in username, posts, comments etc
        #I can make them unique by cutting out by discussion title, discussion title+forum, etc as key.
        #otherwise, if I can assume each unique xml filename is a unique instance I can just use that as key
      p entry.name
      p entry.get_input_stream.read
      p entry
      puts ""
    end
  end
end

def scrape_page_for_zip_hrefs(url)
  doc = Nokogiri::HTML(open(url))
  array_of_href = []
    # could not figure out how to get .map to skip the parent directory link
  doc.css('td a').each do |link|
      array_of_href << url+link['href'] if link['href'].include? "zip"
  end
  array_of_href
end

def big_momma(url)
  scrape_page_for_zip_hrefs(url).each do |zip_url|
    save_single_zip_to_hash(zip_url)
  end
end

# norman = Redis.new(:host => 'localhost', :port => 9393)
save_single_zip_to_redis("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1463284643656.zip","h")
