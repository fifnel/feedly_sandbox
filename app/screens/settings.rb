class SettingsScreen < PM::GroupedTableScreen

  title 'Settings'

  def table_data
    [
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
  end

  def on_load
    self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
  end

  def login
    open_modal FeedlyAuthScreen.new nav_bar:true
  end

  def foo
    PM.logger.debug 'foo'
  end

end
