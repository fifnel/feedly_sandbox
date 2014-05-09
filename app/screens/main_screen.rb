class MainScreen < PM::TableScreen

  def on_load
    set_nav_bar_button :right, title:"Test", action: :open_test

    set_nav_bar_button :left, title:"API", action: :api_test
  end

  def open_test
    # open AuthScreen
    # open FeedlyAuthScreen
    open_modal FeedlyAuthScreen.new nav_bar:true
  end

  def api_test
    unless OAuthAPI.setup("https://sandbox.feedly.com")
      p 'oauth setup failure'
      return
    end

    OAuthAPI.request('/v3/subscriptions') do |response, responseData, error|
      pp response
      pp responseData
      pp error
    end
  end

  def open_dummy
    App.alert('dummy')
  end

  def table_data
    # @table_data ||= []
    @table_data = [{
      cells: [
        {
          title: 'foobar',
          action: :open_dummy,
          arguments: {}
        }
      ]
    }]
  end

  def on_return(args)
    case args[:screen]
    when FeedlyAuthScreen::SCREEN_NAME
      if args[:result] == :succeeded
        identifier = args[:identifier]
        App::Persistence['foobar'] = identifier
        account = NXOAuth2AccountStore.sharedStore.accountWithIdentifier(identifier)

        # API Access Test
        targetUrl = 'https://sandbox.feedly.com/v3/subscriptions'.nsurl
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
