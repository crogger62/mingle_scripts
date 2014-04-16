require "uri"
require "net/https"
require "time"
require "api_auth"
require 'nokogiri'
require 'csv'

class String
  def blank?
    empty?
  end
end


def get(url, access_key_id, secret_access_key)

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  ApiAuth.sign!(request, access_key_id, secret_access_key)

  response = http.request(request)

  Nokogiri::XML(response.body)
end

if ARGV.length < 4
  p "USAGE: Please pass in the following arguments: "
  p "1. host                      - e.g. https://some.mingle.thoughtworks.com"
  p "2. access_key_id             - your username"
  p "3. secret_access_key(part 1) - the HMAC key from your profile, the part before newline"
  p "3. secret_access_key(part 2) - the HMAC key from your profile, the part after newline"
else
  host = ARGV[0]
  access_key_id = ARGV[1]
  secret_access_key = "#{ARGV[2]}\n#{ARGV[3]}"

  hostname = URI.parse(host).hostname

  url = "#{host}/api/v2/projects.xml?name_and_id_only"
  doc = get(url, access_key_id, secret_access_key)
  identifiers = doc.xpath("//identifier").map(&:text)


  CSV.open("#{hostname}.csv", "wb+") do |csv|
    csv << ["Project Identifier", "Last Updated At"]
    identifiers.each do |identifier|

      url = "#{host}/api/v2/projects/#{identifier}/feeds/events.xml"
      doc = get(url, access_key_id, secret_access_key)

      doc.remove_namespaces!
      last_updated_time = doc.xpath("//entry//updated").map(&:text).first
      csv << [identifier, last_updated_time]

      puts "Project #{identifier} was last updated at #{last_updated_time.inspect}"
    end
  end
end
