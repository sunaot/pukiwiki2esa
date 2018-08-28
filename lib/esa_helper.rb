require 'yaml'
class EsaCredentials
  def self.credentials(group_name = 'default')
    config = YAML::load_file('.esa/credentials')
    config.fetch(group_name)
  end
end

if $0 == __FILE__
  pp EsaCredentials.credentials
end
