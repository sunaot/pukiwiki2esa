require 'yaml'
class Config
  @config = YAML::load_file('.config/file')

  def self.wiki_path
    @config['wiki_path']
  end

  def self.bucket
    @config['bucket']
  end
end

if $0 == __FILE__
  pp Config.wiki_path
  pp Config.bucket
end
