class FeedsScreen < PM::TableScreen

  attr_accessor :id

  title 'Feeds'

  def table_data
    @feeds ||= []
    [{
      cells: @feeds.map do |item|
        {
          title: item['title'],
          action: :detail_feed,
          arguments: { id: item['id']}

        }
        end
    }]
  end

  def on_load
    set_nav_bar_button :right, system_item: :refresh, action: :refresh
    refresh
  end

  def refresh
    self.navigationItem.rightBarButtonItem.enabled = false
    FeedlyOAuth.instance.request("/v3/subscriptions") do |response, responseData, error|
      res = BW::JSON.parse(responseData)
      unless error
        @feeds = res.find_all do |item|
          item['categories'].each do |category|
            if id == @id
              break true
            end
            false
          end
        end
        update_table_data
      end
      PM.logger.debug "response:#{response}"
      PM.logger.debug "responseData:#{responseData}"
      PM.logger.debug "error:#{error}"
      self.navigationItem.rightBarButtonItem.enabled = true
    end
  end

end

