require "httparty"
require "nokogiri"
require "csv"

response = HTTParty.get("https://www.scrapingcourse.com/ecommerce/")
document = Nokogiri::HTML(response.body)
Product = Struct.new(:url, :image, :name, :price)

html_products = document.css("li.product")

products = []

html_products.each do | html_product |
  url = html_product.css("a").first.attribute("href").value
  image = html_product.css("img").first.attribute("src").value
  name = html_product.css("h2").first.text
  price = html_product.css("span").first.text

  product = Product.new(url, image, name, price)

  products.push(product)
end

csv_headers = %w{url image name price}
CSV.open("output.csv", "wb", write_headers: true, headers: csv_headers) do | csv |
  products.each do | product |
    csv << product
  end
end