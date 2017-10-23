#!/usr/bin/env ruby
# coding: utf-8

require 'rack'
require 'rack/contrib'

module Cometa
  class Server
    def self.run options = {}
      opts = {}
      opts[:Host] = options[:Host] || '0.0.0.0'
      opts[:Port] = options[:Port] || 80
      
      server = Rack::Builder.new do |env|
        root = "app"

        map "/" do
          use Rack::TryStatic, 
              :urls => Dir.glob("#{root}/*").map { |f| f.sub(root, '') },
              :root => File.expand_path(root),
              :try  => ["index.html", "/index.html"]
        end

        map "/public/" do
          use Rack::Static, :root => "public"
        end

        not_found = lambda do |env|
          content = File.read("app/404.html")
          [
            404,
            {'Content-Type' => 'text/html', 'Content-Length' => content.length.to_s},
            [content]
          ]
        end

        run not_found
      end
      
      Rack::Handler.pick(["thin", "puma"]).run server, opts
    end
  end
end

# main
if __FILE__ == $0
  puts "Starting Cometa server..."
  Cometa::Server.run Port: 8080
end
