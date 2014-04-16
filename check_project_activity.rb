require 'net/http'
require 'nokogiri'
require 'open-uri'

uri = URI('http://localhost:3000/api/v2/projects.xml')
request = Net::HTTP::Get.new(uri) # => String
request.basic_auth "admin", "p"

response = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(request)
}

doc = Nokogiri::XML(response.body)
identifiers = doc.xpath("//identifier").map(&:text)

identifiers.each do |identifier|

  uri = URI("http://localhost:3000/api/v2/projects/#{identifier}/feeds/events.xml")
  request = Net::HTTP::Get.new(uri)


  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  doc = Nokogiri::XML(response.body)

  doc.remove_namespaces!
  last_updated_time = doc.xpath("//entry//updated").map(&:text).first

  puts "Project #{identifier} was last updated at #{last_updated_time.inspect}"

end
