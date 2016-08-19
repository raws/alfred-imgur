module Imgur
  class Client
    BUNDLE_ID = 'com.rosspaffett.alfred.imgur'
    DATA_PATH = File.expand_path("~/Library/Application Support/Alfred 3/Workflow Data/#{BUNDLE_ID}")
    IMGUR_CLIENT_ID = '2aa10e158556a25'
    IMGUR_CLIENT_SECRET = '1a60f2bd5d604ba24771ba382991fb809a72e9af'
    LOG_PATH = File.expand_path("~/Library/Logs/#{BUNDLE_ID}.log")
    SETTINGS_PATH = DATA_PATH + '/settings.json'

    include HTTMultiParty
    base_uri 'https://api.imgur.com'

    def upload(file_path)
      options = {
        headers: { 'Authorization' => "Bearer #{access_token}" },
        query: { image: File.new(file_path) }
      }

      response = self.class.post('/3/image.json', options)

      if response.code == 200
        Upload.new(id: response['data']['id'], link: response['data']['link']).tap do |upload|
          logger.info "Uploaded #{file_path.inspect} to #{upload.link.inspect}"
        end
      elsif access_token_has_expired?(response)
        logger.info 'Access token has expired. Refreshing it and retrying...'
        refresh_access_token
        upload file_path
      elsif access_token_is_invalid?(response)
        logger.info 'Access token is invalid. Prompting user to reauthorize...'
        prompt_for_authorization
        upload file_path
      else
        logger.error "An error occurred while attempting to upload #{file_path.inspect}: " +
          "#{response.parsed_response.inspect} (HTTP #{response.code})"
        nil
      end
    end

    private

    def access_token
      access_token_from_cache || prompt_for_authorization
    end

    def access_token_from_cache
      settings['access_token']
    end

    def access_token_has_expired?(response)
      response.code == 403 && response['data']['error'] =~ /access token.*?expired/i
    end

    def access_token_is_invalid?(response)
      response.code == 403 && response['data']['error'] =~ /access token.*?invalid/i
    end

    def display_dialog(message, prompt_for_answer = false)
      script = "osascript -e 'tell app \"Finder\" to return the text returned of (display dialog \"#{message}\""
      script << ' default answer ""' if prompt_for_answer
      script << ")'"

      `#{script}`.strip.tap do
        if $? != 0
          logger.error "osascript exited with status #{$?} on display_dialog(#{message.inspect})"
          exit 1
        end
      end
    end

    def exchange_pin_for_access_token
      options = {
        query: {
          client_id: IMGUR_CLIENT_ID,
          client_secret: IMGUR_CLIENT_SECRET,
          grant_type: 'pin',
          pin: prompt_for_pin
        }
      }

      response = self.class.post('/oauth2/token', options)

      if response.code == 200
        settings['access_token'] = response['access_token']
        settings['refresh_token'] = response['refresh_token']

        write_settings

        settings['access_token']
      end
    end

    def exchange_refresh_token_for_access_token
      options = {
        query: {
          client_id: IMGUR_CLIENT_ID,
          client_secret: IMGUR_CLIENT_SECRET,
          grant_type: 'refresh_token',
          refresh_token: settings['refresh_token']
        }
      }

      response = self.class.post('/oauth2/token', options)

      if response.code == 200
        settings['access_token'] = response['access_token']
        settings['refresh_token'] = response['refresh_token']
        write_settings
      end
    end

    def logger
      @logger ||= ::Logger.new(LOG_PATH).tap do |logger|
        logger.level = ::Logger::DEBUG
      end
    end

    def notify(message, options = {})
      Notification.new(message, options).notify
    end

    def open_authorization_prompt_in_browser
      params = HTTParty::HashConversions.to_params(client_id: IMGUR_CLIENT_ID,
        response_type: 'pin', state: 'authorize')
      url = "#{self.class.base_uri}/oauth2/authorize?#{params}"
      Launchy.open(url)
    end

    def prompt_for_authorization
      open_authorization_prompt_in_browser

      if access_token = exchange_pin_for_access_token
        access_token
      else
        notify 'Could not authenticate with Imgur.', subtitle: 'An error occurred'
      end
    end

    def prompt_for_pin
      display_dialog 'Accept the prompt in your browser, then enter the PIN given to you by Imgur:', true
    end

    def read_settings
      if File.exists?(SETTINGS_PATH)
        File.open(SETTINGS_PATH) do |io|
          JSON.parse(io.read)
        end
      else
        {}
      end
    rescue => e
      logger.error "Could not read settings from #{SETTINGS_PATH}: #{e}"
      {}
    end

    def refresh_access_token
      if settings['refresh_token']
        exchange_refresh_token_for_access_token
      else
        prompt_for_authorization
      end
    end

    def settings
      @settings ||= read_settings
    end

    def write_settings
      unless File.directory?(DATA_PATH)
        Dir.mkdir(DATA_PATH)
      end

      File.open(SETTINGS_PATH, 'w') do |io|
        json = JSON.pretty_generate(settings)
        io.write(json)
      end
    rescue => e
      logger.error "Could not write settings to #{SETTINGS_PATH}: #{e}"
    end
  end
end
