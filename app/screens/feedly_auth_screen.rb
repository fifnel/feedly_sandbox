class FeedlyAuthScreen < PM::WebScreen

  title 'Feedly Login'
  ACCOUNT_TYPE = 'Feedlysandbox'
  SCREEN_NAME = :FeedlyAuthScreen

  class << self
    def open_modal(parent_screen)
      parent_screen.open_modal self.new nav_bar:true
    end
  end

  def content
    'about:blank'
  end

  def on_load
    # ナビゲーションバーの下にWebViewが初期表示時に重なってしまう問題の対処(iOS 7.x以降)
    if self.respondsToSelector('edgesForExtendedLayout')
      self.edgesForExtendedLayout = UIRectEdgeNone
    end

    set_nav_bar_button :left, system_item: :refresh, action: :start_request
    set_nav_bar_button :right, system_item: :cancel, action: :close
  end

  def view_will_appear(animated)
    @oauth2_succeed_observer = App.notification_center.observe(NXOAuth2AccountStoreAccountsDidChangeNotification) { |notification|
      account =  notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey]
      close(screen: SCREEN_NAME, result: :succeeded)
    }

    @oauth2_failure_observer = App.notification_center.observe(NXOAuth2AccountStoreDidFailToRequestAccessNotification) { |notification|
      # TODO 失敗の理由とか教えてあげたい
      App.alert('OAuthの認証に失敗しました')
      close(screen: SCREEN_NAME, result: :failed)
    }

    start_request
  end

  def view_will_disappear(animated)
    App.notification_center.unobserve @oauth2_succeed_observer
    App.notification_center.unobserve @oauth2_failure_observer
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
    NXOAuth2AccountStore.sharedStore.requestAccessToAccountWithType(ACCOUNT_TYPE,
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

  def load_started
    BW::NetworkIndicator.show
  end

  def load_finished
    BW::NetworkIndicator.hide
  end

  def load_failed(error)
    BW::NetworkIndicator.hide
  end

end
