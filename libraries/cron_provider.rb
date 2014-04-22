
require 'chef/resource'

# patch cron provider to recognize and delete puppet crons :D

class Chef
  class Resource
    class Cron
      def puppet(arg = nil)
        set_or_return(
          :puppet,
          arg,
          kind_of: [TrueClass, FalseClass]
        )
      end
    end
  end
end

class Chef
  class Provider
    class Cron
      def load_current_resource
        crontab_lines = []
        @current_resource = Chef::Resource::Cron.new(@new_resource.name)
        @current_resource.user(@new_resource.user)
        status = popen4("crontab -l -u #{@new_resource.user}") do |pid, stdin, stdout, stderr|
          stdout.each_line { |line| crontab_lines << line }
        end
        if status.exitstatus > 1
          fail Chef::Exceptions::Cron, "Error determining state of #{@new_resource.name}, exit: #{status.exitstatus}"
        elsif status.exitstatus == 0
          cron_found = false
          crontab_lines.each do |line|
            case line.chomp
            when "# Chef Name: #{@new_resource.name}"
              Chef::Log.debug("Found cron '#{@new_resource.name}'")
              cron_found = true
              @cron_exists = true
              next
            when "# Puppet Name: #{@new_resource.name}"
              Chef::Log.debug("Found Puppet Cron '#{@new_resource.name}'")
              if @new_resource.puppet == true
                cron_found = true
                @cron_exists = true
                next
              end
            when /^MAILTO=(\S*)/
              @current_resource.mailto(Regexp.last_match[1]) if cron_found
              next
            when /^PATH=(\S*)/
              @current_resource.path(Regexp.last_match[1]) if cron_found
              next
            when /^SHELL=(\S*)/
              @current_resource.shell(Regexp.last_match[1]) if cron_found
              next
            when /^HOME=(\S*)/
              @current_resource.home(Regexp.last_match[1]) if cron_found
              next
            when CRON_PATTERN
              if cron_found
                @current_resource.minute(Regexp.last_match[1])
                @current_resource.hour(Regexp.last_match[2])
                @current_resource.day(Regexp.last_match[3])
                @current_resource.month(Regexp.last_match[4])
                @current_resource.weekday(Regexp.last_match[5])
                @current_resource.command(Regexp.last_match[6])
                cron_found = false
              end
              next
            else
              next
            end
          end
          Chef::Log.debug("Cron '#{@new_resource.name}' not found") unless @cron_exists
        elsif status.exitstatus == 1
          Chef::Log.debug("Cron empty for '#{@new_resource.user}'")
          @cron_empty = true
        end

        @current_resource
      end

      def action_delete
        if @cron_exists
          crontab = ''
          cron_found = false
          status = popen4("crontab -l -u #{@new_resource.user}") do |pid, stdin, stdout, stderr|
            stdout.each_line do |line|
              case line.chomp
              when "# Chef Name: #{@new_resource.name}"
                cron_found = true
                next
              when "# Puppet Name: #{@new_resource.name}"
                Chef::Log.debug " Going to remove Puppet Cron: #{@new_resource.name}"
                if @new_resource.puppet == true
                  cron_found = true
                  next
                end
              when CRON_PATTERN
                if cron_found
                  cron_found = false
                  next
                end
              else
                next if cron_found
              end
              crontab << line
            end
          end

          status = popen4("crontab -u #{@new_resource.user} -", waitlast: true) do |pid, stdin, stdout, stderr|
            crontab.each_line { |line| stdin.puts "#{line}" }
          end
          Chef::Log.debug("Deleted cron '#{@new_resource.name}'")
          @new_resource.updated_by_last_action(true)
        end
      end
    end
  end
end
