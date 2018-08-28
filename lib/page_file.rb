require 'cgi'
require 'pathname'
require 'config'

class PageFile
  attr_reader :database

  def initialize(root_path: Config.wiki_path)
    @database = scan_dir(root_path)
  end

  def names
    @database.keys
  end

  def pages
    @database
  end

  def self.decode(name)
    decoded = name.delete_suffix('.txt')
    CGI.unescape decoded.chomp.scan(/../).map {|s| "%#{s}" }.join
  end

  def scan_dir(root_path)
    Pathname.glob(root_path+'/wiki/[0-9A-Z]*.txt').inject({}) do |result, path|
      name = PageFile.decode(path.basename.to_s)
      result[name] = { page: name, source: path.basename.to_s }
      result
    end
  end
end

if $0 == __FILE__
  require 'yaml'
  puts PageFile.new.pages.to_yaml
end
