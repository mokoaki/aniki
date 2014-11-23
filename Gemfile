source 'https://rubygems.org'
ruby '2.1.5'

gem 'rails', '4.1.8'
gem 'mysql2'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'therubyracer',  platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'

gem 'bcrypt'

#gem 'jbuilder', '~> 2.0'
#gem 'sdoc', '~> 0.4.0',          group: :doc

group :production do
  gem 'unicorn'
end

group :development do
  gem 'whenever', :require => false
  gem 'rspec-rails'
  gem "spring"
  gem 'spring-commands-rspec'
  gem 'pry-rails'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  #gem 'selenium-webdriver', '2.35.1'
  #gem 'capybara-webkit'

  ###capybaraはSeleniumのdriverがデフォで入る？
  ###yum install xvfb
  ###gem 'headless'
  ###http://d.hatena.ne.jp/sandmark/20120324/1332590065
end
