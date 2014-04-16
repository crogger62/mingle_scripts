require "uri"
require "net/https"
require "time"
require "api_auth"
require 'nokogiri'
require 'csv'

def get(url, username, password, basic_auth)

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if (url =~ /^https/)

  request = Net::HTTP::Get.new(uri.request_uri)
  if basic_auth
    request.basic_auth username, password
  else
    ApiAuth.sign!(request, username, password)
  end

  response = http.request(request)

  Nokogiri::XML(response.body)
end

if ARGV.length < 4
  p "USAGE: Please pass in the following arguments: "
  p "1. host                         - e.g. https://some.mingle.thoughtworks.com"
  p "2. auth_mechanism               - e.g. Basic or HMAC"
  p "3. username                     - your username"
  p "4. secret_access_key | password - If using basic auth, your password, otherwise split the HMAC secret key into separate args by line breaks"
else
  host = ARGV[0]
  basic_auth = (ARGV[1] =~ /Basic/i) == 0
  username = ARGV[2]
  password = ARGV[3..-1].join("\n")

  hostname = URI.parse(host).hostname

  url = "#{host}/api/v2/projects.xml"
  doc = get(url, username, password, basic_auth)
  projects = doc.xpath("//project")


  CSV.open("#{hostname}.csv", "wb+") do |csv|
    csv << ["Project Name", "Last Updated On"]
    projects.each do |project|

      identifier = project.xpath(".//identifier").text
      name = project.xpath(".//name").first.text
      template = project.xpath(".//template").text

      next if template == "true"

      url = "#{host}/api/v2/projects/#{identifier}/feeds/events.xml"
      doc = get(url, username, password, basic_auth)

      doc.remove_namespaces!
      last_updated_time = doc.xpath("//entry//updated").map(&:text).first
      last_updated_date = last_updated_time ? Time.parse(last_updated_time).to_date.to_s : nil
      csv << [name, last_updated_date]

      puts "Project #{name} (#{identifier}) was last updated on #{last_updated_date.inspect}"
    end
  end
end
