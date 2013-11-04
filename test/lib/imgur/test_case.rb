module Imgur
  class TestCase < Test::Unit::TestCase
    def self.test(name, &block)
      define_method "test #{name.inspect}", &block
    end
  end
end
