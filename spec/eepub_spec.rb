require 'spec_helper'

require 'tempfile'
require 'zip'

RSpec.describe Eepub do
  example do
    epub = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))

    expect(epub.title).to eq 'Metamorphosis '
  end

  example 'change title and save' do
    orig = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))
    orig.title = 'foo <bar>'

    expect(orig.title).to eq 'foo <bar>'

    dest = Tempfile.create
    orig.save_to dest.path

    updated = Eepub.load_from(dest.path)

    expect(updated.title).to eq 'foo <bar>'
  end

  example 'mimetype entry remains uncompressed' do
    orig = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))
    dest = Tempfile.create
    orig.save_to dest.path

    saved = Eepub.load_from(dest.path)

    Zip::File.open dest.path do |zip|
      mimetype = zip.find_entry('mimetype')

      expect(mimetype.compression_method).to eq Zip::Entry::STORED
    end
  end
end
