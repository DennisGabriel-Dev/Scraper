require "httparty"
require "nokogiri"
require "csv"
require "parallel"

Product = Struct.new(:url, :image, :name, :price)
products = Array.new

pages_to_scrape = [
  "https://www.scrapingcourse.com/ecommerce/page/1/",
	"https://www.scrapingcourse.com/ecommerce/page/3/",
	"https://www.scrapingcourse.com/ecommerce/page/4/",
	"https://www.scrapingcourse.com/ecommerce/page/5/", 
	"https://www.scrapingcourse.com/ecommerce/page/6/"
]

semaphore = Mutex.new

Parallel.map(pages_to_scrape, in_threads: 4) do |page_to_scrape|
  response = HTTParty.get(page_to_scrape)
  document = Nokogiri.HTML5(response.body)

  html_products = document.css("li.product")
  html_products.each do |html_product|
    url = html_product.css("a").attribute("href").value
    image = html_product.css("img").first.attribute("src").value
    name = html_product.css("h2").first.text
    price = html_product.css("span").first.text
    semaphore.synchronize{
      products << Product.new(url, image, name, price)
    }
  end
end
csv_headers = %w{url image name price}
CSV.open("output.csv", "wb", write_headers: true, headers: csv_headers) do |csv|
  products.each do |product|
    csv << product
  end
end