class FeedScreen < PM::GroupedTableScreen

  attr_accessor :id

  title 'FeedDetail'

  @feed = nil

  def table_data
    if @feed.nil?
      []
    else
      [
        {
          title: 'title',
          cells: [{ title: @feed['title'] }]
        },{
          title: 'velocity',
          cells: [{ title: @feed['velocity'].to_s }]
        },{
          title: 'subscribers',
          cells: [{ title: @feed['subscribers'].to_s }]
        },{
          title: 'language',
          cells: [{ title: @feed['language'] }]
        },{
          title: 'website',
          cells: [{ title: @feed['website'] }]
        },{
          title: 'description',
          cells: [{ title: @feed['description'] }]
        }
      ]
    end
  end

  def on_load
    set_nav_bar_button :right, system_item: :refresh, action: :refresh
    refresh
  end

  def refresh
    self.navigationItem.rightBarButtonItem.enabled = false
    FeedlyOAuth.instance.request("/v3/feeds/#{self.id.escape_url}") do |response, responseData, error|
      unless error
        @feed = BW::JSON.parse(responseData)
        update_table_data
      end
      self.navigationItem.rightBarButtonItem.enabled = true
      PM.logger.debug "response:#{response}"
      PM.logger.debug "responseData:#{responseData}"
      PM.logger.debug "error:#{error}"
    end
  end

end
