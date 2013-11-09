require 'test_helper'

module Imgur
  class NotificationTest < TestCase
    test 'creating a notification' do
      options = { title: 'A title', open: 'http://example.com' }
      notification = Notification.new('A message', options)

      assert_equal 'A message', notification.message
      assert_equal options, notification.options
    end

    test 'sending a notification' do
      TerminalNotifier.stubs :notify
      Notification.new('A message', title: 'A title', open: 'http://example.com').notify

      assert_received TerminalNotifier, :notify do |expect|
        expect.with 'A message', title: 'A title', open: 'http://example.com'
      end
    end
  end
end
