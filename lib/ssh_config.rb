# TODO load ~/.ssh/config only by default, switch for all
# TODO pass custom config file

require 'net/ssh/config'
require 'net/ssh/proxy/command'

module Ssh
  class Config
    def initialize(hosts)
      @hosts = hosts
      @results = {}
    end

    def print
      require 'pry'; binding.pry

      results.each do |host, value|
        puts "Host\t#{host}"
        puts value.map { |k, v| "#{k}\t#{v}" }.sort.join("\n")
      end
    end

    def pretty_print
      require 'pry'; binding.pry

      longest = results.values
        .map(&:values).flatten.map { |l| l.length }.max

      results.each do |host, config|
        puts sprintf("%-#{longest}s %s", 'Host', host)

        config.each do |key, value|
          puts sprintf("%-#{longest}s %s", key.to_s.split('_').map(&:capitalize).join, value)
        end
      end
    end

    def results
      if @results.empty?
        @hosts.each do |host|
          config = Net::SSH::Config.for(host)
          config.each do |key, value|
            case value
            when Net::SSH::Proxy::Command
              config[key] = value.command_line_template
            when Array
              config[key] = value.join(',')
            when String
            else
              config[key] = value.to_s
            end
          end

          @results[host] = config
        end
      end

      @results
    end
  end
end

