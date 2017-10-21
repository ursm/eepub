require 'nokogiri'
require 'zip'
require 'fileutils'

module Eepub
  class Epub
    def initialize(path)
      @path = path
    end

    def title
      @title ||= Zip::File.open(@path) {|zip|
        package_xml = Nokogiri::XML.parse(package_entry(zip).get_input_stream)

        package_xml.at_xpath('//dc:title/text()', dc: 'http://purl.org/dc/elements/1.1/').content
      }
    end

    attr_writer :title

    def save_to(dest_path)
      FileUtils.cp @path, dest_path

      Zip::File.open dest_path do |zip|
        entry      = package_entry(zip)
        xml        = Nokogiri::XML.parse(entry.get_input_stream)
        title_node = xml.at_xpath('//dc:title', dc: 'http://purl.org/dc/elements/1.1/')

        title_node.content = title

        zip.get_output_stream entry.name do |stream|
          stream.write xml.to_s
        end

        zip.commit
      end
    end

    private

    def package_entry(zip)
      container_xml = Nokogiri::XML.parse(container_entry(zip).get_input_stream)

      path = container_xml.at_xpath('//container:rootfile/@full-path', container: 'urn:oasis:names:tc:opendocument:xmlns:container').value

      zip.find_entry(path)
    end

    def container_entry(zip)
      zip.find_entry('META-INF/container.xml')
    end
  end
end
