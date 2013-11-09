require 'test_helper'

module Imgur
  class NotificationTest < TestCase
    test 'creating a notification' do
      options = { open: 'http://example.com', title: 'A title' }
      notification = Notification.new('A message', options)

      expected_options = {
        open: 'http://example.com',
        sender: 'com.runningwithcrayons.Alfred-2',
        title: 'A title'
      }

      assert_equal 'A message', notification.message
      assert_equal expected_options, notification.options
    end

    test 'sending a notification' do
      TerminalNotifier.stubs :notify
      Notification.new('A message', subtitle: 'A subtitle').notify

      expected_options = {
        sender: 'com.runningwithcrayons.Alfred-2',
        subtitle: 'A subtitle',
        title: 'Upload to Imgur'
      }

      assert_received TerminalNotifier, :notify do |expect|
        expect.with 'A message', expected_options
      end
    end
  end
end
