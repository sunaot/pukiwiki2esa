require 'test_helper'
require 'page_retriever'

class PageRetrieverTest < Minitest::Test
  def setup
    @retriever = PageRetriever.new('Asmaru/Visions')
  end

  def test_find
    page = @retriever.find('plans/折込広告/README')
    assert_equal 1981, page[:number]
  end

  def test_page_number_README
    page = @retriever.find_page('plans/折込広告')
    assert_equal 1981, page[:number]
  end

  def test_page_number_path_match
    page = @retriever.find_page('../TimeToThink')
    assert_equal 498, page[:number]
  end

  def test_resolve_link
    assert_equal '/posts/498',
      @retriever.resolve_link('../TimeToThink')
  end

  def test_resolve_link_category
    assert_equal '#path=%2Fplans',
      @retriever.resolve_link('plans')
  end

  def test_resolve_link_nested_category
    assert_equal '#path=%2FJavaScript%2FTips',
      @retriever.resolve_link('JavaScript/Tips')
  end
end
