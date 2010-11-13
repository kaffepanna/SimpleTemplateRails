
gem "haml-rails"
gem 'authlogic', :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'
gem "declarative_authorization"
gem "factory_girl_rails", :group => [:development, :test]
gem "rspec-rails", :group => [:development, :test]

say_status("removing", "prototype", :blue)
%w(rails.js controls.js dragdrop.js effects.js prototype.js).each do |js|
  remove_file "public/javascripts/#{js}"
end
say_status("fetching", "jQuery", :blue)
get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.js",     "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js", "public/javascripts/jquery.min.js"

say_status("fetching", "jQuery UI", :blue)
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.js",     "public/javascripts/jquery-ui.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js", "public/javascripts/jquery-ui.min.js"

say_status("fetching", "jQuery UJS adapter (head)", :blue)
get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"

sentinel = "Application.configure do\n"
javascripts_development = 'config.action_view.javascript_expansions[:defaults] = %w(jquery.js jquery-ui.js rails.js)'
javascripts_production = 'config.action_view.javascript_expansions[:defaults] = %w(jquery.min.js jquery-ui.min.js rails.js)'
inject_into_file 'config/environments/development.rb', "\n  #{javascripts_development}\n", :after => sentinel, :verbose => false
inject_into_file 'config/environments/production.rb', "\n  #{javascripts_production}\n", :after => sentinel, :verbose => false

haml_sass = <<-INIT_HAML_SASS
  Sass::Plugin.options[:template_location] = File.join(Rails.root, 'app', 'views', 'sass')    
  Haml::Template.options[:format] = :html5
INIT_HAML_SASS

environment haml_sass
empty_directory 'app/views/sass'
create_file "app/views/sass/base.scss", "html { }"

layout = <<-LAYOUT
!!!
%html
  %head
    %title #{app_name.humanize}
    %meta{:charset => 'utf-8'}
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    = yield
LAYOUT

remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.haml", layout

remove_dir "test"

run "bundle install"

generate :'rspec:install'

generate :controller, 'welcome', 'index'
route "root :to => 'welcome#index'" 
remove_file 'public/index.html'
