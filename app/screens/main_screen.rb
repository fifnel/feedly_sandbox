class MainScreen < PM::TableScreen

  def on_load

    set_nav_bar_button :right, title:"Test", action: :open_test

    set_nav_bar_button :left, title:"API", action: :api_test

    @indicator ||= add UIActivityIndicatorView.gray, {
      center: [view.frame.size.width / 2, view.frame.size.height / 2 - 42]
    }
    @indicator.startAnimating
  end

  def on_appear
    unless OAuth.authorized?
      FeedlyAuthScreen.open_modal(self)
    end
  end

  def open_test
    # open AuthScreen
    # open FeedlyAuthScreen
    open_modal FeedlyAuthScreen.new nav_bar:true
  end

  def api_test
    # unless OAuth.setup("https://sandbox.feedly.com")
    #   p 'oauth setup failure'
    #   return
    # end

    # OAuth.request('/v3/subscriptions') do |response, responseData, error|
    #   pp response
    #   pp responseData
    #   pp error
    # end
  end

  def open_dummy
    App.alert('dummy')
  end

  def table_data
    @table_data ||= [{
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
    # case args[:screen]
    # when FeedlyAuthScreen::SCREEN_NAME
    #   if args[:result] == :succeeded
    #     OAuth.request('/v3/subscriptions') do |response, responseData, error|
    #       pp response
    #       pp responseData
    #       pp error
    #     end
    #   else
    #   end
    # end
  end

end
