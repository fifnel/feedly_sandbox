module SingletonClass
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def new
      super
      instance
    end

    def instance
      Dispatch.once { @instance ||= alloc.init }
      @instance
    end
  end
end

class FeedlyOAuth
  include SingletonClass

  attr_accessor :account_type, :client_id, :client_secret
  attr_accessor :redirect_url, :base_url, :auth_url, :token_url, :scope_url

  def initial_setup
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
      setup_account(account.identifier)
    }

    @oauth2_failure_observer ||= App.notification_center.observe(NXOAuth2AccountStoreDidFailToRequestAccessNotification) { |notification|
    }

    setup_account
  end

  def finalize
    App.notification_center.unobserve @oauth2_succeed_observer
    App.notification_center.unobserve @oauth2_failure_observer
  end

  def setup_account(account_identifier = nil)
    if account_identifier
      App::Persistence['account_identifier'] = account_identifier
    else
      account_identifier ||= App::Persistence['account_identifier']
    end

    @account = NXOAuth2AccountStore.sharedStore.accountWithIdentifier(account_identifier)
    PM::logger.info("account identifier:#{account_identifier}")
  end

  def relese_account
    App::Persistence.delete('account_identifier')
    @account = nil
  end

  def authorized?
    @account ? true : false
  end

  def request(api, method='GET', progress_handler=nil, &block)
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
