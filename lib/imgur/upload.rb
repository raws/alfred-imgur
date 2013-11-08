module Imgur
  class Upload
    attr_reader :error, :id, :link

    def initialize(options)
      @error = options[:error]
      @id = options[:id]
      @link = options[:link]
    end

    def successful?
      error.nil?
    end
  end
end
