require 'test_helper'

module Imgur
  class UploadingTest < TestCase
    test 'attempting an upload without authorization' do
      client = Client.new
      # client.upload('example.jpg')
    end

    test 'attempting an upload with an expired access token' do
      # TODO
    end

    test 'attempting an upload with an invalid access token' do
      # TODO
    end

    test 'attempting to upload a non-image file' do
      # TODO
    end

    test 'successfully uploading an image' do
      # TODO
    end

    test 'successfully uploading several images' do
      # TODO
    end

    test 'successfully uploading one image and getting an error for another' do
      # TODO
    end
  end
end
