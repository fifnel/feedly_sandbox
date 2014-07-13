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
    p 'hoge'
    pp self.id
  end

  def detail_feed(args={})
    open FeedScreen.new(nav_bar: true, id:args[:id])
  end

  def refresh
    self.navigationItem.rightBarButtonItem.enabled = false
    FeedlyOAuth.instance.request("/v3/subscriptions") do |response, responseData, error|
      res = BW::JSON.parse(responseData)
      unless error
        @feeds = res.find_all do |item|
          item['categories'].each do |category|
            if self.id == category['id']
              break true
            end
            false
          end
        end
        update_table_data
      end
      self.navigationItem.rightBarButtonItem.enabled = true
      PM.logger.debug "response:#{response}"
      PM.logger.debug "responseData:#{responseData}"
      PM.logger.debug "error:#{error}"
    end
  end

end

