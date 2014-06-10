class AppDelegate < PM::Delegate

  def on_load(app, options)

    FeedlyOAuth.instance.initial_setup
    
    open SettingsScreen.new(nav_bar: true) # for debug
    # open MainScreen.new(nav_bar: true)
  end

end
