require 'test_helper'

module Imgur
  class UploadTest < TestCase
    test 'a successful upload' do
      upload = Upload.new(id: 'EiX7Uvg', link: 'https://i.imgur.com/EiX7Uvg.png')

      assert_nil upload.error
      assert_equal 'EiX7Uvg', upload.id
      assert_equal 'https://i.imgur.com/EiX7Uvg.png', upload.link
      assert upload.successful?
    end

    test 'an unsuccessful upload' do
      upload = Upload.new(error: 'Access token has expired')

      assert_equal 'Access token has expired', upload.error
      assert_nil upload.id
      assert_nil upload.link
      refute upload.successful?
    end
  end
end
