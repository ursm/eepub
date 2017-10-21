require 'fileutils'
require 'rexml/document'
require 'zip'

module Eepub
  class Epub
    def initialize(path)
      @path = path
    end

    attr_reader :path

    def title
      @title ||= Zip::File.open(@path) {|zip|
        package_xml = REXML::Document.new(package_entry(zip).get_input_stream)

        package_xml.elements['//dc:title'].text
      }
    end

    attr_writer :title

    def save!(to: path)
      FileUtils.cp path, to unless path == to

      Zip::File.open to do |zip|
        entry      = package_entry(zip)
        xml        = REXML::Document.new(entry.get_input_stream)
        title_node = xml.elements['//dc:title']

        title_node.text = title

        zip.get_output_stream entry.name do |stream|
          stream.write xml.to_s
        end

        zip.commit
      end
    end

    private

    def package_entry(zip)
      container_entry = zip.find_entry('META-INF/container.xml')
      container_xml   = REXML::Document.new(container_entry.get_input_stream)
      path            = container_xml.elements['//rootfile/@full-path'].value

      zip.find_entry(path)
    end
  end
end
