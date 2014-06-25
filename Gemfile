source 'https://rubygems.org'

gem 'rails', '4.1.1'
gem 'mysql2'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'therubyracer',  platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
#gem 'jbuilder', '~> 2.0'
#gem 'sdoc', '~> 0.4.0',          group: :doc

group :production do
  gem 'unicorn'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'whenever', :require => false
  gem 'rspec-rails'
  gem "spring"
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'guard-rspec'
  gem 'guard-spring'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  #gem 'selenium-webdriver', '2.35.1'
  #gem 'capybara-webkit'

  ###capybaraはSeleniumのdriverがデフォで入る？
  ###yum install xvfb
  ###gem 'headless'
  ###http://d.hatena.ne.jp/sandmark/20120324/1332590065
end

gem 'bcrypt'
