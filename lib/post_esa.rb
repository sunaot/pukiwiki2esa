require 'esa'
require 'page_file'
require 'yaml'
require 'esa_helper'

DRYRUN = false
CONTINUE = true

root_dir = 'esa'
class DryRunClient
  def create_post(params)
    pp params
  end
end

client = if DRYRUN
  DryRunClient.new
else
  credentials = EsaCredentials.credentials
  Esa::Client.new(access_token: credentials['access_token'], current_team: credentials['current_team'])
end

pages = if CONTINUE
  YAML.load_file('esa_pages')
else
  PageFile.new.pages
end

pages.each do |name, page|
  puts "start: #{name}"
  body = File.read("#{root_dir}/#{page[:source]}")
  m = name.match(%r{(.*)/(.*)})
  if m
    category, title = m[1], m[2]
  else
    category, title = '', name
  end

  client.create_post({
    name: title,
    body_md: body,
    category: category,
    wip: false,
    message: 'Convert from PukiWiki',
    user: 'sunaot'
  })
  puts "  end: #{name}"
end
