$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pukiwiki2md'
require 'page_file'
require 'page_retriever'
require 'file_retriever'
require 'cgi'
require 'config'

Esanize = ->(page_name, transform) {
  transform.module_eval do
    rule(:inner_link => simple(:name), :l => simple(:l), :r => simple(:r)) do
      if name == 'FrontPage'
        '<!-- FrontPage -->'
      else
        retriever = PageRetriever.new(page_name)
        link = retriever.resolve_link(name.to_s)
        !link.empty? ? "[#{name}](#{link})" : "[#{name}]"
      end
    end

    rule(:child_pages => simple(:s)) do
      name = page_name.delete_suffix('/README')
      "[#{name}の子ページ](/#path=%2F#{CGI.escape(name)})" + ::Pukiwiki2md::Transform::EOL
    end

    rule(:block_image => simple(:image), :l => simple(:l), :r => simple(:r)) {
      retriever = FileRetriever.new(page_name)
      "![#{image}](#{retriever.find(image)})" + ::Pukiwiki2md::Transform::EOL
    }

    rule(:block_file => simple(:file), :l => simple(:l), :r => simple(:r)) {
      retriever = FileRetriever.new(page_name)
      "[#{file}](#{retriever.find(file)})" + ::Pukiwiki2md::Transform::EOL
    }

    rule(:image => simple(:image), :l => simple(:l), :r => simple(:r)) {
      retriever = FileRetriever.new(page_name)
      "![#{image}](#{retriever.find(image)})"
    }

    rule(:file => simple(:file), :l => simple(:l), :r => simple(:r)) {
      retriever = FileRetriever.new(page_name)
      "[#{file}](#{retriever.find(file)})"
    }
  end
  transform
}

class EsaFile
  def initialize(page_name)
    @parser = ::Pukiwiki2md::Parser.new
    esa = Esanize.call(page_name, Class.new(::Pukiwiki2md::Transform))
    @trans = esa.new
  end

  def run(text)
    result = @parser.parse(text)
    @trans.apply(result)
  end
end

if $0 == __FILE__
  page_file = PageFile.new
  page_file.pages.each do |name, page|
    puts "==========================="
    puts "    name: #{name}"
    puts "  source: #{page[:source]}"
    puts "==========================="
  
    esa = EsaFile.new(name)
    wiki_text = File.read("#{Config.wiki_path}/wiki/#{page[:source]}")
  
    File.open("esa/#{page[:source]}", 'w') do |f|
      f.puts esa.run(wiki_text)
      f.puts FileRetriever.new(name).markdown_links
    end
  end
end
