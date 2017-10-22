# coding: utf-8
# Generate pages from individual records in yml files
# (c) 2014-2016 Adolfo Villafiorita
# (c) 2017 David Charte
# Distributed under the conditions of the MIT License

module Jekyll

  # this class is used to tell Jekyll to generate a page
  class DataPage < Page

    # - site and base are copied from other plugins: to be honest, I am not sure what they do
    #
    # - `index_files` specifies if we want to generate named folders (true) or not (false)
    # - `dir` is the default output directory
    # - `data` is the data defined in `_data.yml` of the record for which we are generating a page
    # - `name` is the key in `data` which determines the output filename
    # - `template` is the name of the template for generating the page
    # - `extension` is the extension for the generated file
    def initialize(site, base, index_files, dir, data, data_name, template, extension)
      @site = site
      @base = base

      # @dir is the directory where we want to output the page
      # @name is the name of the page to generate
      #
      # the value of these variables changes according to whether we
      # want to generate named folders or not
      filename = data_name.to_s
      if index_files
        @dir = dir + (index_files ? "/" + filename + "/" : "")
        @name =  "index" + "." + extension.to_s
      else
        @dir = dir
        @name = filename + "." + extension.to_s
      end

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template + ".html")
      # self.data['title'] = data[name]
      self.data['title'] = data_name
      # add all the information defined in _data for the current record to the
      # current page (so that we can access it with liquid tags)
      self.data['data'] = data
    end
  end

  class DataPagesGenerator < Generator
    safe true

    # generate retrieves configuration _config.yml/page_gen invoking the DataPage
    # constructor for each data file for which we want to generate a page

    def generate(site)
      # page_gen_dirs determines whether we want to generate index pages
      # (name/index.html) or standard files (name.html). This information
      # is passed to the DataPage constructor, which sets the @dir variable
      # as required by this directive
      puts "debug"
      index_files = site.config['page_gen-dirs']
      index_files = true if index_files.nil?

      # config contains the specification of the data for which we want to generate
      # the pages (look at the README file for its specification)
      config = site.config['data_gen']

      # default configuration: get all data files, use the 'data_page.html' template,
      # output to /data
      path = nil
      template = 'data_page'
      dir = 'data'
      
      
      if config
        path = config['path'] || path
        template = config['template'] || template
        dir = config['dir'] || dir
      end

      if site.layouts.key? template
        data_files = path.nil? ? site.data : site.data[path]

        data_files.each do |name, record|
          site.pages << DataPage.new(site, site.source, index_files, dir, record, name, template, "html")
        end
      else
        puts "DataPageGenerator error. could not find template #{template}"
      end
    end
  end

  module DataPageLinkGenerator
    # use it like this: {{input | datapage_url: dir}}
    # to generate a link to a data_page.
    #
    # the filter is smart enough to generate different link styles
    # according to the data_page-dirs directive 
    def datapage_url(input, dir)
      extension = Jekyll.configuration({})['page_gen-dirs'] ? '/' : '.html'
      "#{dir}/#{input}#{extension}"
    end
  end

end

Liquid::Template.register_filter(Jekyll::DataPageLinkGenerator)

