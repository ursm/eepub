require 'fileutils'
require 'rexml/document'
require 'zip'

using Module.new {
  refine Hash do
    def slice(*keys)
      keys.each_with_object({}) {|k, h|
        h[k] = self[k]
      }
    end
  end
} unless {}.respond_to?(:slice)

module Eepub
  class Epub
    XMLNS = {
      'container' => 'urn:oasis:names:tc:opendocument:xmlns:container',
      'dc'        => 'http://purl.org/dc/elements/1.1/',
    }

    def initialize(path)
      @path = path
    end

    attr_reader :path

    def title
      @title ||= Zip::File.open(path) {|zip|
        rootfile_doc = rootfile_entry(zip).get_input_stream(&REXML::Document.method(:new))

        REXML::XPath.first(rootfile_doc, '//dc:title', XMLNS.slice('dc')).text
      }
    end

    attr_writer :title

    def save!(to: path)
      FileUtils.cp path, to unless path == to

      Zip::File.open to do |zip|
        rootfile_entry = rootfile_entry(zip)
        rootfile_doc   = rootfile_entry.get_input_stream(&REXML::Document.method(:new))

        REXML::XPath.first(rootfile_doc, '//dc:title', XMLNS.slice('dc')).text = title

        zip.get_output_stream rootfile_entry.name do |stream|
          stream.write rootfile_doc.to_s
        end

        zip.commit
      end
    end

    private

    def rootfile_entry(zip)
      container_doc = zip.find_entry('META-INF/container.xml').get_input_stream(&REXML::Document.method(:new))
      rootfile_path = REXML::XPath.first(container_doc, '//container:rootfile/@full-path', XMLNS.slice('container')).value

      zip.find_entry(rootfile_path)
    end
  end
end
