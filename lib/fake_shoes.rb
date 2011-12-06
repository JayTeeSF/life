class FakeShoes
  class << self
    def app
      @app ||= FakeApp.new
    end
  end
  class FakeApp
    def method_missing method_sym, *args, &block
      puts "#{caller[0]} called: #{method_sym} w/ #{args.inspect}"
      self.instance_eval(&block) if block_given?
    end
  end
end
