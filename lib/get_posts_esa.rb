require 'esa'
require 'yaml'
require 'esa_helper'

credentials = EsaCredentials.credentials
client = Esa::Client.new(access_token: credentials['access_token'], current_team: credentials['current_team'])
page = 1
while(true)
  response = client.posts('per_page' => 100, 'page' => page)

  posts = response.body['posts']
  File.open('esa_posts', 'a') do |f|
    f.write(posts.map {|post| { number: post['number'], full_name: post['full_name'] } }.to_yaml)
  end
  break if response.body['next_page'].nil?
  page += 1
end

