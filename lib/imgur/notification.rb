module Imgur
  class Notification
    DEFAULTS = {
      sender: 'com.runningwithcrayons.Alfred-2',
      title: 'Upload to Imgur'
    }

    attr_reader :message, :options

    def initialize(message, options = {})
      @message = message
      @options = DEFAULTS.merge(options)
    end

    def notify
      TerminalNotifier.notify(message, options)
    end
  end
end
