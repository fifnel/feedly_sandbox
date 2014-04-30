class TestScreen < PM::Screen

  def on_load
    set_nav_bar_button :right, system_item: :add, action: :hoge
  end

  def hoge
    
  end

end
