require 'cgi'
require 'pathname'
require 'config'
class AttachmentFile
  attr_reader :filenames

  def initialize(root_path: Config.wiki_path)
    @filenames = scan_dir(root_path)
  end

  private
  def decode(name)
    page, file = name.split('_')
    {
      source: name,
      page: CGI.unescape(page.chomp.scan(/../).map {|s| "%#{s}" }.join),
      file: CGI.unescape(file.chomp.scan(/../).map {|s| "%#{s}" }.join)
    }
  end

  def scan_dir(root_path)
    Pathname.glob(root_path+'/attach/[0-9A-Z]*_[0-9A-Z]*[^.log]').inject([]) do |result, path|
      result << decode(path.basename.to_s)
    end
  end
end

if $0 == __FILE__
  pp AttachmentFile.new.filenames
end
