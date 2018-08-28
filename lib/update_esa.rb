require 'esa'
require 'page_file'
require 'yaml'
require 'esa_helper'

DRYRUN = false

root_dir = 'esa'
class DryRunClient
  def update_post(number, params)
    pp(number, params)
  end
end

client = if DRYRUN
  DryRunClient.new
else
  credentials = EsaCredentials.credentials
  Esa::Client.new(access_token: credentials['access_token'], current_team: credentials['current_team'])
end

pages = File.read('update_pages')
esa_pages = YAML.load_file('esa_posts')

pages.each_line(chomp: true) do |page_name|
  name = PageFile.decode(page_name)
  puts "start: #{name}"
  body = File.read("#{root_dir}/#{page_name}")

  page = esa_pages.find {|item| item[:full_name] == name }
  raise("cannot find page: [#{name}]") unless page

  client.update_post(page[:number], {
    body_md: body
  })
  puts "  end: #{name}"
end
