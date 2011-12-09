class FakeShoes
  class << self
    def app(options={}, &block)
      @app ||= FakeApp.new
      @app.eval(block.call)
    end
  end
  class FakeApp
    def method_missing method_sym, *args, &block
      puts "#{caller[0]} called: #{method_sym} w/ #{args.inspect}"
      self.instance_eval(&block) if block_given?
    end
  end
end
