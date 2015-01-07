source 'https://rubygems.org'
ruby '2.2.0'

gem 'rails', '4.2.0'
gem 'mysql2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier'
gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'jquery-form-rails'
gem 'bcrypt'

group :production do
  gem 'unicorn'
end

group :development do
  gem 'rspec-rails'
  gem 'pry-rails'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
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
