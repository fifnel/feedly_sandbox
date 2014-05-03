class AuthScreen < PM::WebScreen
  title 'OAuthTest'

  CLIENT_ID = 'sandbox'
  REDIRECT_URI = 'http://localhost'
  SCOPE = 'https://cloud.feedly.com/subscriptions'
  CLIENT_SECRET = '0AUDIAHZEB0ISJ1JLFWZ'
  AUTH_URI = "http://sandbox.feedly.com/v3/auth/auth?client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&response_type=code&scope=#{SCOPE}"


  def on_init
    super

    @activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    self.view.addSubview(@activity)
    @activity.center = self.view.center
    @activity.hidesWhenStopped = true
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

  def content
    AUTH_URI.nsurl
  end

  def on_request(request, in_type)
    url = request.URL.absoluteString
    # is our redirect url?
    params = Hash.new
    if url.start_with? REDIRECT_URI
      request.URL.query.split('&').each do |str|
        kv = str.split('=')
        params[kv[0]] = kv[1]
      end

      url = "http://sandbox.feedly.com/v3/".nsurl
      oauthClient = AFOAuth2Client.clientWithBaseURL(url, clientID:CLIENT_ID, secret:CLIENT_SECRET)

      oauthClient.authenticateUsingOAuthWithPath("/oauth/token", scope:SCOPE,
        success: lambda { |credential|
          NSLog("I have a token! %@", credential.accessToken)
          AFOAuthCredential.storeCredential(credential,withIdentifier(oauthClient.serviceProviderIdentifier))
        },
        failure: lambda {
          NSLog("Error: %@", error)
        }
      )

      p 'close!!!!!!!!'

      pp params
      pp request, in_type
      close screen: :auth_screen, code: params['code'] 
    end

    true
  end

end
