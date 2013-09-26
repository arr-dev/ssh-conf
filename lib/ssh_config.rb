# TODO load ~/.ssh/config only by default, switch for all
# TODO pass custom config file

require 'json'
require 'net/ssh/config'
require 'net/ssh/proxy/command'

module Ssh
  class Config
    def initialize(hosts, options = {})
      @hosts = hosts
      @options = options
      @results = {}
    end

    def output
      method = "text"

      if @options[:format] == :json
        method = "json"
      end

      if @options[:pretty]
        method = "pretty_#{method}"
      end

      send(method)
    end

    def text
      results.each do |host, config|
        puts "Host\t#{host}"

        config.each do |key, value|
          puts "#{camelize(key)}\t#{value}"
        end
      end
    end

    def pretty_text
      longest = results.values
        .map(&:values).flatten.map { |l| l.length }.max

      results.each do |host, config|
        puts sprintf("%-#{longest}s %s", 'Host', host)

        config.each do |key, value|
          puts sprintf("%-#{longest}s %s", camelize(key), value)
        end
      end
    end

    def json
      puts JSON.dump(results)
    end

    def pretty_json
      puts JSON.pretty_generate(results)
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

    private

    def camelize(str)
      str.to_s.split('_').map(&:capitalize).join
    end
  end
end

