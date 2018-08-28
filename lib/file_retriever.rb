require 'yaml'

class FileRetriever
  def initialize(page_name)
    @index = database.fetch(page_name, Hash.new)
  end

  def find(filename)
    @index.fetch(filename.to_s)
  end

  # view
  def markdown_links
    return if @index.empty?
    links = @index.map do |filename, url|
      "* [#{filename}](#{url})"
    end
    [ '', '# Attachment files', *links ].join("\n")
  end

  def database
    YAML.load_file('files_index')
  end
end
