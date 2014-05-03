class MainScreen < PM::Screen

  def on_load
    set_nav_bar_button :right, title:"Test", action: :open_test
  end

  def open_test
    # open AuthScreen
    open FeedlyAuthScreen
  end

  def on_return(args)
    case args[:screen]
    when FeedlyAuthScreen::SCREEN_NAME
      if args[:result] == :succeeded
        identifier = args[:identifier]
        # App::Persistence['foobar'] = identifier
        account = NXOAuth2AccountStore.sharedStore.accountWithIdentifier(identifier)

        # API Access Test
        targetUrl = 'https://sandbox.feedly.com/v3/profile'.nsurl
        NXOAuth2Request.performMethod('GET',
          onResource: targetUrl,
          usingParameters: nil,
          withAccount: account,
          sendProgressHandler: ->(bytesSend, bytesTotal) {
            pp bytesSend
            pp bytesTotal
          },
          responseHandler: ->(response, responseData, error) {
            pp response
            pp responseData
            pp error
          }
        )
      else
      end
    end
  end

end
