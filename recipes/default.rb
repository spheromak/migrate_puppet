# Cookbook Name:: puppet
# Recipe:: default
#

packages %w(puppet facter) do action :remove end

# example removing puppet crons
cron 'restart_puppet' do
  action :delete
  puppet true
end
