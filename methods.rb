require "rubygems"
require "open-uri"
require "fileutils"
require "zip"
require "nokogiri"
require "redis"


#receives a url of a zip file and sends it to redis specified. Uses a key so if run on the same zip file it won't change the list.
def save_single_zip_to_redis(zip_url,redis)
  file = open(zip_url)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |entry|
      #looks like there are duplicates with slight differences in username, posts, comments etc
        #I can make them unique by cutting out by discussion title, discussion title+forum, etc as key.
        #otherwise, if I can assume each unique xml filename is a unique instance that we want I can just use that as key
      redis.set(entry.name, entry.get_input_stream.read)
      p entry.name
      p entry.get_input_stream.read
      p entry
      puts ""
    end
  end
end

#given a url will return an array of hrefs under the "td a" css selector
def scrape_page_for_zip_hrefs(url)
  doc = Nokogiri::HTML(open(url))
  array_of_href = []
  doc.css('td a').each do |link|
      array_of_href << url+link['href'] if link['href'].include? "zip"
  end
  array_of_href
end

#Combines the two above methods to scrape all the data; takes forever
def scrape_n_save(url, redis)
  scrape_page_for_zip_hrefs(url).each do |zip_url|
    save_single_zip_to_redis(zip_url, redis)
  end
end



