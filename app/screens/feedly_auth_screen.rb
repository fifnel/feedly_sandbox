class FeedlyAuthScreen < PM::WebScreen

  title 'Feedly Auth'

  SCREEN_NAME = :FeedlyAuthScreen

  OAUTH2CLIENT_ACCOUNT_TYPE = "Feedlysandbox"
  OAUTH2CLIENT_CLIENTID     = "sandbox"
  OAUTH2CLIENT_CLIENTSECRET = "0AUDIAHZEB0ISJ1JLFWZ"
  OAUTH2CLIENT_REDIRECTURL  = "http://localhost"
  OAUTH2CLIENT_BASEURL      = "https://sandbox.feedly.com"
  OAUTH2CLIENT_AUTHURL      = "/v3/auth/auth"
  OAUTH2CLIENT_TOKENURL     = "/v3/auth/token"
  OAUTH2CLIENT_SCOPEURL     = "https://cloud.feedly.com/subscriptions"

  def content
    'about:blank'
  end

  def on_load
    set_nav_bar_button :right, system_item: :add, action: :hoge

    @activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    self.view.addSubview(@activity)
    @activity.center = self.view.center
    @activity.hidesWhenStopped = true

    NXOAuth2AccountStore.sharedStore.setClientID(OAUTH2CLIENT_CLIENTID, 
      secret: OAUTH2CLIENT_CLIENTSECRET,
      scope: NSSet.setWithObjects(OAUTH2CLIENT_SCOPEURL, nil),
      authorizationURL: (OAUTH2CLIENT_BASEURL + OAUTH2CLIENT_AUTHURL).nsurl,
      tokenURL: (OAUTH2CLIENT_BASEURL + OAUTH2CLIENT_TOKENURL).nsurl,
      redirectURL: OAUTH2CLIENT_REDIRECTURL.nsurl,
      forAccountType: OAUTH2CLIENT_ACCOUNT_TYPE)
  end

  def view_will_appear(animated)
    @oauth2_succeed_observer = App.notification_center.observe(NXOAuth2AccountStoreAccountsDidChangeNotification) { |notification|
      account =  notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey]
      close screen: SCREEN_NAME, result: :succeeded, identifier: account.identifier
    }

    @oauth2_failure_observer = App.notification_center.observe(NXOAuth2AccountStoreDidFailToRequestAccessNotification) { |notification|
      close screen: SCREEN_NAME, result: :failed
    }

    start_request
  end

  def view_will_disappear(animated)
    App.notification_center.unobserve @oauth2_succeed_observer
    App.notification_center.unobserve @oauth2_failure_observer
  end

  def load_started
    @activity.startAnimating
  end

  def load_finished
    @activity.stopAnimating
  end

  def load_failed(error)
    @activity.stopAnimating
  end

  def on_request(request, type)
    if NXOAuth2AccountStore.sharedStore.handleRedirectURL(request.URL)
      false # OAuth2のリダイレクトリクエストのハンドリングに成功したらリクエストを握りつぶす
    else
      true
    end
  end

  private

  def start_request
    NXOAuth2AccountStore.sharedStore.requestAccessToAccountWithType(OAUTH2CLIENT_ACCOUNT_TYPE,
      withPreparedAuthorizationURLHandler: ->(prepared_url) {
        # cookieを消しておかないと、ログイン済みの各種Webサービスのセッションが生きていて
        # アカウント入力する機会が与えられないままFeedlyにログインされてしまう
        cookie_storage = NSHTTPCookieStorage.sharedHTTPCookieStorage
        cookie_storage.cookies.each { |cookie|
          cookie_storage.deleteCookie(cookie)
        }
        open_url(prepared_url)
      }
    )
  end

end
