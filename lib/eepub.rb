require 'eepub/version'

module Eepub
  autoload :Epub, 'eepub/epub'

  class << self
    def load_from(path)
      Epub.new(path)
    end
  end
end
