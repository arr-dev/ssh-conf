require 'json'

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

      send("as_#{method}")
    end

    def as_text
      out = ''

      results.each do |host, config|
        out << "Host\t#{host}\n"

        config.each do |key, value|
          out << "#{key}\t#{value}\n"
        end
      end

      out
    end

    def as_pretty_text
      longest = results.values.map(&:flatten).flatten
        .max { |a, b| a.length <=> b.length }.length + 2

      out = ''
      results.each do |host, config|
         out << sprintf("%-#{longest}s %s\n", 'Host', host)

        config.each do |key, value|
          out << sprintf("%-#{longest}s %s\n", key, value)
        end

        out << "\n"
      end

      out
    end

    def as_json
      JSON.dump(results)
    end

    def as_pretty_json
      JSON.pretty_generate(results)
    end

    def results
      if @results.empty?
        @hosts.each do |host|
          config = self.for(host)
          config.each do |key, value|
            case value
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

    def for(host)
      files.inject({}) { |settings, file|
        load(file, host, settings)
      }
    end

    def load(path, host, settings={})
      file = File.expand_path(path)
      return settings unless File.readable?(file)

      globals = {}
      matched_host = nil
      seen_host = false
      IO.foreach(file) do |line|
        next if line =~ /^\s*(?:#.*)?$/

        if line =~ /^\s*(\S+)\s*=(.*)$/
          key, value = $1, $2
        else
          key, value = line.strip.split(/\s+/, 2)
        end

        # silently ignore malformed entries
        next if value.nil?

        value = $1 if value =~ /^"(.*)"$/

        value = case value.strip
          when /^\d+$/ then value.to_i
          when /^no$/i then false
          when /^yes$/i then true
          else value
          end

        if key == 'Host'
          # Support "Host host1 host2 hostN".
          # See http://github.com/net-ssh/net-ssh/issues#issue/6
          negative_hosts, positive_hosts = value.to_s.split(/\s+/).partition { |h| h.start_with?('!') }

          # Check for negative patterns first. If the host matches, that overrules any other positive match.
          # The host substring code is used to strip out the starting "!" so the regexp will be correct.
          negative_match = negative_hosts.select { |h| host =~ pattern2regex(h[1..-1]) }.first

          if negative_match
            matched_host = nil
          else
            matched_host = positive_hosts.select { |h| host =~ pattern2regex(h) }.first
          end

          seen_host = true
          settings.delete(key)
        elsif !seen_host
          if key == 'IdentityFile'
            (globals[key] ||= []) << value
          else
            globals[key] = value unless settings.key?(key)
          end
        elsif !matched_host.nil?
          if key == 'IdentityFile'
            (settings[key] ||= []) << value
          else
            settings[key] = value unless settings.key?(key)
          end
        end
      end

      settings = globals.merge(settings) if globals

      return settings
    end

    def files
      if @options[:files]
        @options[:files].split(',')
      elsif @options[:all]
        %w(~/.ssh/config /etc/ssh_config /etc/ssh/ssh_config)
      else
        %w( ~/.ssh/config )
      end
    end

    private

    # Converts an ssh_config pattern into a regex for matching against
    # host names.
    def pattern2regex(pattern)
      pattern = "^" + pattern.to_s.gsub(/\./, "\\.").
        gsub(/\?/, '.').
        gsub(/([+\/])/, '\\\\\\0').
        gsub(/\*/, '.*') + "$"
      Regexp.new(pattern, true)
    end

  end
end

