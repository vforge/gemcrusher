require 'gemcrusher/version'
require 'rubygems'
require 'gems'

module Gemcrusher
  class Crusher
    def crush(source, destination)
      puts 'Going to crush your Gemfile...'
      @gems = []

      if File.exists? source
        mine_gems source
        identify_gems
        save destination
        puts '..crushed into Gemfile.md'
      else
        puts '..but I can\'t find one!'
      end
    end

    private

    def identify_gems
      @gems.map! do |gem|
        name = gem[:name]
        params = gem[:params]

        puts "Found gem '#{name}'"
        info = Gems.info name

        {name: name, params: params, info: info}
      end
    end

    def save(destination)
      File.open(destination, 'w') do |file|
        # header
        file.puts '# Gem list'

        @gems.each do |gem|
          name = gem[:name]
          info = gem[:info]

          # gem header
          file.puts "### #{name}"

          # gem description
          file.puts info['info'].strip

          # gem homepage uri
          homepage_uri = info['homepage_uri'].strip
          file.puts "* #{homepage_uri}"

          # gem project uri
          project_uri = info['project_uri'].strip
          file.puts "* #{project_uri}"
        end
      end
    end

    def mine_gems(source)
      File.foreach(source) do |line|
        case line.strip
          when /^\s*gem\s*['"]([\w-]+)['"]$/
            @gems << {name: $1}
          when /^\s*gem\s*['"]([\w-]+)['"],\s*(.*)$/
            @gems << {name: $1, params: $2}
          else
        end
      end
    end
  end
end
