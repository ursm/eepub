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

        REXML::XPath.first(package_xml, '//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/').text
      }
    end

    attr_writer :title

    def save!(to: path)
      FileUtils.cp path, to unless path == to

      Zip::File.open to do |zip|
        entry      = package_entry(zip)
        xml        = REXML::Document.new(entry.get_input_stream)
        title_node = REXML::XPath.first(xml, '//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/')

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
      path            = REXML::XPath.first(container_xml, '//container:rootfile/@full-path', 'container' => 'urn:oasis:names:tc:opendocument:xmlns:container').value

      zip.find_entry(path)
    end
  end
end
