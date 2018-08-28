require 'yaml'
require 'pathname'
require 'cgi'

class PageRetriever
  def initialize(current_page)
    @current_page = current_page
    @posts = YAML::load_file('esa_posts')
    @categories = categories(@posts).sort.uniq
  end

  def find(page_name)
    @posts.find do |item|
      item[:full_name] == page_name
    end
  end

  def resolve_link(target_page)
    page = find_page(target_page)
    category = @categories.find {|name| name == target_page }

    generate_link(page, category, target_page)
  end

  def find_page(target_page)
    @posts.find do |item|
      if target_page.start_with?('./', '../')
        path_match?(item, target_page, @current_page)
      else
        same_page_name?(target_page, item[:full_name])
      end
    end
  end

  private
  def path_match?(item, target_page, current_page)
    path = Pathname.new(current_page) + target_page
    no_readme_path = Pathname.new(current_page.delete_suffix('README')) + target_page
    same_page_name?(path.to_s, item[:full_name]) or
    same_page_name?(no_readme_path.to_s, item[:full_name])
  end

  def generate_link(page, category, original_name)
    if page
      "/posts/#{page[:number]}"
    elsif category
      "/#path=#{CGI.escape('/'+category)}"
    else
      $stderr.puts original_name
      ''
    end
  end

  def same_page_name?(target_name, page_name)
    page_name == target_name ||
    page_name.delete_suffix('/README') == target_name
  end

  def categories(posts)
    posts.reduce([]) do |result, item|
      category, title = category_name(item[:full_name])
      unless category == ''
        result.push category
      end
      result
    end
  end

  def category_name(page_name)
    m = page_name.match(%r{(.*)/(.*)})
    if m
      category, title = m[1], m[2]
    else
      category, title = '', page_name
    end
  end
end
