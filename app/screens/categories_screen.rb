class CategoriesScreen < PM::TableScreen

  title 'Categories'

  def table_data
    @categories ||= []
    [{
      cells: @categories.map do |item|
        {
          title: item['label'],
          action: :detail_category,
          arguments: { id: item['id'], title: item['label'] }
        }
        end
    }]
  end

  def on_load
    set_nav_bar_button :right, system_item: :refresh, action: :refresh
    refresh
  end

  def detail_category(args={})
    open FeedsScreen.new(nav_bar: true, title:args[:title], id:args[:id])
  end

  def refresh
    self.navigationItem.rightBarButtonItem.enabled = false
    FeedlyOAuth.instance.request('/v3/categories') do |response, responseData, error|
      res = BW::JSON.parse(responseData)
      unless error
        @categories = res
        update_table_data
      end
      self.navigationItem.rightBarButtonItem.enabled = true
      PM.logger.debug "response:#{response}"
      PM.logger.debug "responseData:#{responseData}"
      PM.logger.debug "error:#{error}"
    end
  end

end
