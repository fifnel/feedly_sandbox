class OAuthAPI
  class << self

    def setup(base_url, accout_id = nil)
      @@base_url = base_url.nsurl
      if accout_id.nil?
        account_id = App::Persistence['foobar'] # TODO: foobarどうにかする
      end
      @@account = NXOAuth2AccountStore.sharedStore.accountWithIdentifier(account_id)
    end

    def request(api, method='GET', progress_handler=nil, &block)
      target_url = (@@base_url.absoluteString + api).nsurl
      pp target_url

      NXOAuth2Request.performMethod(method,
        onResource: target_url,
        usingParameters: nil,
        withAccount: @@account,
        sendProgressHandler: ->(bytesSend, bytesTotal) {
          unless progress_handler.nil?
            progress_handler.call(bytesSend, bytesTotal)
          end
        },
        responseHandler: ->(response, responseData, error) {
          unless block.nil?
            block.call(response, responseData, error)
          end
        }
      )
    end

  end
end
