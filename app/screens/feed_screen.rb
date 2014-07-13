class FeedScreen < PM::TableScreen

  attr_accessor :id

  title 'FeedDetail'

  def table_data
    []
    # @feeds ||= []
    # [{
    #   cells: @feeds.map do |item|
    #     {
    #       title: item['title'],
    #       action: :detail_feed,
    #       arguments: { id: item['id']}

    #     }
    #     end
    # }]
  end

  def on_load
    set_nav_bar_button :right, system_item: :refresh, action: :refresh
    refresh
    pp self.id.escape_url
  end

  def refresh
    self.navigationItem.rightBarButtonItem.enabled = false
    FeedlyOAuth.instance.request("/v3/feeds/#{self.id.escape_url}") do |response, responseData, error|
      res = BW::JSON.parse(responseData)
      PM.logger.debug "response:#{response}"
      PM.logger.debug "responseData:#{responseData}"
      PM.logger.debug "error:#{error}"
      self.navigationItem.rightBarButtonItem.enabled = true
    end
  end

end

