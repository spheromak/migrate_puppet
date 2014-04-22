source  'https://rubygems.org'

# lock berks2 and < solve 1.0
gem 'berkshelf', '~> 2.0.14'
gem 'solve', '~> 0.8.2'
gem 'faraday', '~> 0.8.9'

group 'develop' do
  gem 'unf'
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'kitchen-docker'
  gem 'kitchen-ec2',
      git: 'https://github.com/test-kitchen/kitchen-ec2.git'
  gem 'rake'
  gem 'foodcritic',
      git: 'https://github.com/mlafeldt/foodcritic.git',
      branch: 'improve-rake-task'
  gem 'rubocop'
  gem 'guard'
  gem 'guard-rake'
  gem 'guard-kitchen'
  gem 'knife-cookbook-doc'
  gem 'chefspec', '>= 3.2.0'
  gem 'git'
end
