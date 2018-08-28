$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pukiwiki2md'

EsaTransform = Class.new(::Pukiwiki2md::Transform)

Esanize = ->(page_name, transform) {
  transform.module_eval do
    rule(:inner_link => simple(:name), :l => simple(:l), :r => simple(:r)) { "[#{name}](/posts?q=title%3A#{name})" }

    rule(:child_pages => simple(:s)) do
      "[#{page_name}の子ページ](/#path=%2F#{page_name})" + ::Pukiwiki2md::Transform::EOL
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

class FileRetriever
  def initialize(page_name)
    @index = database.fetch(page_name)
  end

  def find(filename)
    @index.fetch(filename.to_s)
  end

  def database
    {
      '並カン' => {
        'image.png' => 'https://example.com/image.png',
        'namikan_1_goyoki.pdf' => 'https://example.com/namikan_1_goyoki.pdf',
        'parallel-programing-brief.pptx' => 'https://example.com/parallel-programing-brief.pptx',
        'そろそろvolatileについて一言いっておくか.ppt' => 'https://example.com/そろそろvolatileについて一言いっておくか.ppt',
        'マルチコア時代のLock-free入門.ppt' => 'https://example.com/マルチコア時代のLock-free入門.ppt'
      }
    }
  end
end

class Sample
  def initialize
    @parser = ::Pukiwiki2md::Parser.new
    esa = Esanize.call('並カン', Class.new(::Pukiwiki2md::Transform))
    @trans = esa.new
  end

  def run
    result = @parser.parse(sample_text)
    @trans.apply(result)
  end

  def sample_text
    <<-TEXT
#contents

* Hello, World [#qb249ac2]

This is Wiki text.
Hi, God.

This text shows ''STRONG TEXT'' and '''italic text'''.
%%deleted text%% もこんなかんじ。
これは((footnote なのです))と書くと脚注になる。
[[Blog:http://example.com/blog]]はブログへのリンク。
&ref(namikan_1_goyoki.pdf);と書くと添付ファイルで
さらに &ref(image.png); とすると画像表示

** FrontPage [#e652f146]

[[プロセス監視]]

#br

> Quotation text
> This is also quotation text

- This is unordered list
- This is also unordered list
-- Indent level 2
--- Indent level 3

+ This is ordered list
+ This is also ordered list
++ Indent level 2
+++ Indent level 3

#ref(マルチコア時代のLock-free入門.ppt)

#ref(parallel-programing-brief.pptx)

#ref(image.png)

#ls

|aaa|bbb|ccc|h
| 1 | 2 | 3 |
| 4 | 5 | 6 |

| 1 | 2 | 3 |
| 4 | 5 | 6 |
| 7 | 8 | 9 |

----
- ul following to ----

: definition term 1 | and description 1
: definition term 2 | and description 2
: definition term 3 | and description 3

 This is preformatted text.
 This text is like <pre> tag.

#hr

#clear

* Hello, World

#clear but it's normal paragraph
Hello, again.
    TEXT
  end
end

puts Sample.new.run
