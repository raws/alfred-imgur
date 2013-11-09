module Imgur
  class Notification
    attr_reader :message, :options

    def initialize(message, options = {})
      @message = message
      @options = options
    end

    def notify
      TerminalNotifier.notify(message, options)
    end
  end
end
