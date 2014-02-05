source 'https://rubygems.org'

# Specify your gem's dependencies in conjur.gemspec
gemspec

gem 'conjur-api', git: 'https://github.com/inscitiv/api-ruby.git', branch: 'master'

group :test, :development do
  gem 'thin'
  gem 'eventmachine'
  gem 'pry'
  gem 'conjur-asset-environment-api'
  gem 'conjur-asset-layer-api'
end
