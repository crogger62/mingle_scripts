require 'net/http'
require 'nokogiri'

def get(url, username, password)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri) # => String
  request.basic_auth username, password

  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  Nokogiri::XML(response.body)
end

host = ARGV[0]
username = ARGV[1]
password = ARGV[2]

url = "#{host}/api/v2/projects.xml"
doc = get(url, username, password)
identifiers = doc.xpath("//identifier").map(&:text)

identifiers.each do |identifier|

  url = "#{host}/api/v2/projects/#{identifier}/feeds/events.xml"
  doc = get(url, username, password)

  doc.remove_namespaces!
  last_updated_time = doc.xpath("//entry//updated").map(&:text).first

  puts "Project #{identifier} was last updated at #{last_updated_time.inspect}"

end
