class FeedlyOAuth
  include SingletonClass

  attr_accessor :account_type, :client_id, :client_secret
  attr_accessor :redirect_url, :base_url, :auth_url, :token_url, :scope_url

  def initialize
    self.account_type   = "Feedlysandbox"
    self.client_id      = "sandbox"
    self.client_secret  = "ES3R6KCEG46BW9MYD332"
    self.redirect_url   = "http://localhost"
    self.base_url       = "https://sandbox.feedly.com"
    self.auth_url       = "/v3/auth/auth"
    self.token_url      = "/v3/auth/token"
    self.scope_url      = "https://cloud.feedly.com/subscriptions"

    NXOAuth2AccountStore.sharedStore.setClientID(self.client_id, 
      secret: self.client_secret,
      scope: NSSet.setWithObjects(self.scope_url, nil),
      authorizationURL: (self.base_url + self.auth_url).nsurl,
      tokenURL: (self.base_url + self.token_url).nsurl,
      redirectURL: self.redirect_url.nsurl,
      forAccountType: self.account_type)

    @oauth2_succeed_observer ||= App.notification_center.observe(NXOAuth2AccountStoreAccountsDidChangeNotification) { |notification|
      account =  notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey]
      self.account_identifier = account.identifier
    }

    @oauth2_failure_observer ||= App.notification_center.observe(NXOAuth2AccountStoreDidFailToRequestAccessNotification) { |notification|
    }

    load
  end

  def dealloc
    App.notification_center.unobserve @oauth2_succeed_observer
    App.notification_center.unobserve @oauth2_failure_observer
  end

  def account_identifier=(account_identifier)
    PM::logger.info('hogehogehoge')
    if account_identifier.nil?
      @account = nil
    else
      @account = NXOAuth2AccountStore.sharedStore.accountWithIdentifier(account_identifier)
    end
    @account_identifier = account_identifier
    PM::logger.info("account identifier:#{@account_identifier}")
  end

  def save
    if @account_identifier.nil?
      App::Persistence.delete('account_identifier')
    else
      App::Persistence['account_identifier'] = @account_identifier
    end
  end

  def load
    self.account_identifier = App::Persistence['account_identifier']
  end

  def authorized?
    @account ? true : false
  end

  def request(api, method='GET', progress_handler=nil, &block)
    PM::logger.info("account identifier:#{@account_identifier}")
    PM::logger.info("account identifier:#{@account}")
    target_url = (self.base_url.nsurl.absoluteString + api).nsurl
    PM::logger.info(target_url)

    NXOAuth2Request.performMethod(method,
      onResource: target_url,
      usingParameters: nil,
      withAccount: @account,
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
