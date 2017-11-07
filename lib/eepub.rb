# frozen_string_literal: true

module Eepub
  autoload :Epub,    'eepub/epub'
  autoload :VERSION, 'eepub/version'

  class << self
    def load_from(path)
      Epub.new(path)
    end
  end
end
