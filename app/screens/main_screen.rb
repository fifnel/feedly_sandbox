class MainScreen < PM::Screen

  def on_load
    set_nav_bar_button :right, title:"Test", action: :open_test
  end

  def open_test
    open AuthScreen
  end



end
