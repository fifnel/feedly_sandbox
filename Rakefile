# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'feedly_sandbox'

  app.frameworks += ['Security']

  app.pods do
    pod 'NXOAuth2Client', :git => 'https://github.com/takuran/OAuth2Client.git'  
  end
end
