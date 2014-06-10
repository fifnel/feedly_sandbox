class SettingsScreen < PM::GroupedTableScreen

  title 'Settings'

  def table_data
    @table_content ||= []
  end

  def on_load
    # ナビゲーションバーの下にWebViewが初期表示時に重なってしまう問題の対処(iOS 7.x以降)
    if self.respondsToSelector('edgesForExtendedLayout')
      self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
    end

    @table_content = [
      {
        title: 'Feedly',
        cells: [
          { title:'Login', action: :login}
        ]
        },
        {
          title: 'About',
          cells: [
            { title:'foo', action: :foo}
          ]
        }
      ]

    PM::logger.debug FeedlyOAuth.instance.authorized?
    if FeedlyOAuth.instance.authorized?
      @table_content[0][:cells][0][:title] = 'Logout'
      @table_content[0][:cells][0][:action] = :logout
      update_table_data
    end

  end

  def login
    FeedlyAuthScreen.open_modal(self)
  end

  def logout
  end

  def foo
    FeedlyOAuth.instance.request('/v3/subscriptions') do |response, responseData, error|
      PM.logger.debug response
      PM.logger.debug responseData
      PM.logger.debug error
    end
  end

end
