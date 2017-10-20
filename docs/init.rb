#!/usr/bin/env ruby

require 'highline'

class CometaMenu
  attr_accessor :cli
  
  def initialize
    self.cli = HighLine.new
    welcome
    start_menu
  end

  def welcome
    cli.say <<EOF
____________________________________________________________
      
#{"Welcome to cometa".center 60}
____________________________________________________________

EOF
  end

  def first
    datasets = Dir["public/full/*.rds"]

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
      
    end
  end

  def summarize
  end

  def launch
  end

  def start_menu
    cli.choose do |menu|
      menu.prompt = "Please select an option > "
      menu.choice("Interactive first-run") do
        first
        partition
      end
      
      menu.choice("Partition datasets") do
        first
        partition
      end
      
      menu.choice("Create summaries of your data") do
        first
      end
      
      menu.choice("Launch cometa server") do
      end
    end
  end
end


CometaMenu.new

# TODO write configuration somewhere and allow to run non-interactively
# read SERVICE=true from environment
# launch docker run --env SERVICE=true
