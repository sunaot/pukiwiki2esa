# usage: bundle exec ruby -Ilib lib/upload.rb
# https://docs.aws.amazon.com/ja_jp/sdk-for-ruby/v3/developer-guide/setup-config.html
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3.html
require 'aws-sdk-s3'
require 'attachment_file'
require 'yaml'
require 'config'

srand(256) # DRYRUN 実行で URI を固定させる
UPLOAD_PATH = 'production/pukiwiki' # : production/pukiwiki, test/pukiwiki
DRYRUN = true

class Uploader
  def initialize(dryrun: false)
    Aws.config.update(credentials: Aws::SharedCredentials.new(profile_name: 'esa'))
    @s3 = Aws::S3::Resource.new(region:'ap-northeast-1')
    @dryrun = dryrun
  end

  def upload(filename, source)
    n = rand(0..1024)
    unless @dryrun
      upload_real(n, filename, source)
    else
      upload_dryrun(n, filename, source)
    end
  end

  private
  def upload_dryrun(n, filename, source)
    $stdout.puts filename
    base_url = "https://#{Config.bucket}.s3.ap-northeast-1.amazonaws.com/"
    base_url + "uploads/#{UPLOAD_PATH}/#{n}/#{filename}"
  end

  def upload_real(n, filename, source)
    obj = @s3.bucket(Config.bucket).object("uploads/#{UPLOAD_PATH}/#{n}/#{filename}")
    if obj.upload_file("#{Config.wiki_path}/attach/#{source}", acl: 'public-read')
      $stdout.puts filename
      return obj.public_url
    else
      $stderr.puts "Error (Upload failure): #{filename}(#{source})"
      return nil
    end
  end
end

reverse_index = {}

attachment_file = AttachmentFile.new
uploader = Uploader.new(dryrun: DRYRUN)
attachment_file.filenames.each do |file|
  # upload
  url = uploader.upload(file[:file], file[:source])

  # index construction
  page = reverse_index[file[:page]] || {}
  page.update(file[:file] => url)
  reverse_index.update(file[:page] => page)
end

File.open('files_index', 'w') {|f| f.write(reverse_index.to_yaml) }
