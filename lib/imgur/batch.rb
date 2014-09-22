module Imgur
  class Batch
    def initialize(paths)
      @client = Client.new
      @paths = paths
    end

    def copy
      if @successful_uploads.any?
        links = @successful_uploads.map(&:link).join("\n")

        Open3.popen2('pbcopy') do |stdin, stdout, thread|
          stdin.print links
          stdin.close
        end
      end
    end

    def notify(options = {})
      Notification.new(message, options).notify
    end

    def upload
      @uploads = @paths.map do |path|
        @client.upload path
      end

      @successful_uploads, @errored_uploads = *@uploads.partition { |upload| upload.successful? }
    end

    private

    def message
      messages = []

      if @successful_uploads.any?
        link_or_links = pluralize('link', 'links', @successful_uploads.size)
        messages << "Copied #{@successful_uploads.size} Imgur #{link_or_links} to the clipboard."
      end

      if @errored_uploads.any?
        image_or_images = pluralize('image', 'images', @errored_uploads.size)
        messages << "#{@errored_uploads.size} #{image_or_images} could not be uploaded."
      end

      messages.join ' '
    end

    def pluralize(singular, plural, count)
      count == 1 ? singular : plural
    end
  end
end
