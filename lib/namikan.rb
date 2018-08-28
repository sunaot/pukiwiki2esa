require 'pukiwiki2md'

EsaTransform = Class.new(::Pukiwiki2md::Transform)

Esanize = ->(page_name, transform) {
  transform.module_eval do
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

  def run(text)
    result = @parser.parse(text)
    @trans.apply(result)
  end
end

if $0 == __FILE__
  puts Sample.new.run(<<-TEXT)
[[並行カンファレンス:https://atnd.org/events/2092]]の資料。とくに「並列プログラミングの入門＆おさらい的な話(主に並列プログラミングにおける注意事項など) : wraith13」の資料である &ref(parallel-programing-brief.pptx); と「lock freeとかmemory barrier : yamasa」の資料 &ref(マルチコア時代のLock-free入門.ppt); &ref(そろそろvolatileについて一言いっておくか.ppt); は当時非常に新鮮でその後の糧と指針となった。

- &ref(namikan_1_goyoki.pdf);
- &ref(マルチコア時代のLock-free入門.ppt);
- &ref(そろそろvolatileについて一言いっておくか.ppt);
- &ref(parallel-programing-brief.pptx);

あとHaskellネタが2つあったんだけどね。なぜか添付に失敗する。
TEXT
end
