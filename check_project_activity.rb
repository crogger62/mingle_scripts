require "uri"
require "net/https"
require "time"
require "api_auth"
require 'nokogiri'
require 'csv'

def get(url, access_key_id, secret_access_key)

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  ApiAuth.sign!(request, access_key_id, secret_access_key)

  response = http.request(request)

  Nokogiri::XML(response.body)
end

if ARGV.length < 3
  p "USAGE: Please pass in the following arguments: "
  p "1. host                      - e.g. https://some.mingle.thoughtworks.com"
  p "2. access_key_id             - your username"
  p "3. secret_access_key         - split the key into separate args by line breaks"
else
  host = ARGV[0]
  access_key_id = ARGV[1]
  secret_access_key = ARGV[2..-1].join("\n")

  hostname = URI.parse(host).hostname

  url = "#{host}/api/v2/projects.xml?name_and_id_only"
  doc = get(url, access_key_id, secret_access_key)
  identifiers = doc.xpath("//identifier").map(&:text)


  CSV.open("#{hostname}.csv", "wb+") do |csv|
    csv << ["Project Identifier", "Last Updated On"]
    identifiers.each do |identifier|

      url = "#{host}/api/v2/projects/#{identifier}/feeds/events.xml"
      doc = get(url, access_key_id, secret_access_key)

      doc.remove_namespaces!
      last_updated_time = doc.xpath("//entry//updated").map(&:text).first
      last_updated_date = last_updated_time ? Time.parse(last_updated_time).to_date.to_s : nil
      csv << [identifier, last_updated_date]

      puts "Project #{identifier} was last updated on #{last_updated_date.inspect}"
    end
  end
end
