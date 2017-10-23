#!/usr/bin/env ruby

require 'highline'
require_relative 'server.rb'

module Cometa
  module Scripts
    def self.partition *args
      system %[scripts/partition_mld.r #{args.join " "}]
    end
    
    def self.metadata *args
      system %[scripts/dataset_metadata.r #{args.join " "}]
    end
    
    def self.compile
      system "[ -d public/json ] && cp public/json/* site/_data/datasets"
      system "bundle exec jekyll build -s site -d app"
    end
    
    def self.serve
      Cometa::Server.run
    end
  end

  class Menu
    attr_accessor :cli, :datasets
    
    def initialize
      self.cli = HighLine.new
      self.datasets = Dir["public/full/*.rds"]
      
      start_menu
    end

    def first
      if datasets.empty?
        cli.say "We didn't find any datasets in the 'public/full' directory."
        exit(1) unless cli.agree("Continue with no datasets? > ")
      end
    end

    def partition
      cli.say <<EOF
Cometa can automatically partition your datasets for cross-validation uses. Should you so desire, Cometa will generate partitions for hold-out, 1x10 and 2x5 cross validation strategies in a variety of file formats. This process could take from minutes to hours depending on the number of datasets and their size.

EOF

      if cli.agree("Do you want to partition your datasets? > ")
        datasets.each do |mld|
          Scripts.partition mld
        end
      end
    end

    def summarize
      datasets.each do |mld|
        cli.say "Now summarizing #{mld}..."
        Scripts.metadata mld
      end
    end

    def start_menu
      begin
        cli.choose do |menu|
          menu.header = cli.color("Welcome to Cometa", :blue)
          menu.prompt = "\nPlease select an option > "
          
          # menu.choice("Interactive first-run") do
          #   first
          #   cli.newline
          #   partition
          #   cli.newline
          
          #   summarize
          #   cli.newline

          #   jekyll_compile
          #   cli.newline
          #   launch_app
          #   cli.newline

          #   start_menu
          # end
          
          menu.choice("Partition datasets") do
            first
            cli.newline
            partition
            cli.newline
            start_menu
          end
          
          menu.choice("Create summaries of your data") do
            first
            cli.newline
            summarize
            cli.newline
            start_menu
          end
          
          menu.choice("Launch Cometa server") do
            Scripts.compile
            cli.newline
            Scripts.serve
            cli.newline
            start_menu
          end

          menu.choice("Quit") do
            if cli.agree("Are you sure? > ")
              exit(0)
            else
              start_menu
            end
          end
        end
      rescue EOFError
        exit(-1)
      end
    end
  end
end

if ARGV[0] == "menu"
  Cometa::Menu.new
else
  Cometa::Scripts.compile
  Cometa::Scripts.serve
end
