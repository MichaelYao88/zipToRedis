require_relative "methods"

NEWS_XML = Redis.new
scrape_n_save("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/",NEWS_XML)
