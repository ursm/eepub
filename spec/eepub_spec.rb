require 'spec_helper'

require 'fileutils'
require 'tempfile'
require 'zip'

RSpec.describe Eepub do
  example 'read title' do
    epub = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))

    expect(epub.title).to eq 'Metamorphosis '
  end

  example 'read title in multibyte' do
    epub = Eepub.load_from(file_fixture('test-epub3.epub'))
    expect(epub.title).to eq 'テストあいうえお［⓴⓸❿㉓㊿ⓚ㋚㊤㊧㈱］'
  end

  example 'change title and save' do
    orig = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))
    orig.title = 'foo <bar>'

    expect(orig.title).to eq 'foo <bar>'

    dest = Tempfile.create
    orig.save! to: dest.path

    updated = Eepub.load_from(dest.path)

    expect(updated.title).to eq 'foo <bar>'
  end

  example 'in-place update' do
    file = Tempfile.create

    FileUtils.cp file_fixture('Metamorphosis-jackson.epub'), file.path

    orig = Eepub.load_from(file.path)
    orig.title = 'UPDATED'
    orig.save!

    updated = Eepub.load_from(file.path)

    expect(updated.title).to eq 'UPDATED'
  end

  example 'mimetype entry remains uncompressed' do
    orig = Eepub.load_from(file_fixture('Metamorphosis-jackson.epub'))
    dest = Tempfile.create
    orig.save! to: dest.path

    Zip::File.open dest.path do |zip|
      mimetype = zip.find_entry('mimetype')

      expect(mimetype.compression_method).to eq Zip::Entry::STORED
    end
  end
end
