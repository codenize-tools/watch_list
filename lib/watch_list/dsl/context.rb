class WatchList::DSL::Context
  class << self
    def eval(dsl, path, opts = {})
      self.new(path, opts) {
        eval(dsl, binding, path)
      }
    end
  end # of class methods

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    instance_eval(&block)
  end

  def require(file)
   robotfile = File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(robotfile)
      instance_eval(File.read(robotfile), robotfile)
    elsif File.exist?(robotfile + '.rb')
      instance_eval(File.read(robotfile + '.rb'), robotfile + '.rb')
    else
      Kernel.require(file)
    end
  end

  def monitor(name, &block)
    raise 'Monitor: "friendlyname" is required' unless name
    raise "Monitor `#{name}` is already defined" if @result[name]
    @result[friendlyname] << WatchList::DSL::Context::Monitor.new(name, &block).result
  end

  def alert_contact(&block)
    @result[friendlyname] << WatchList::DSL::Context::AlertContent.new(&block).result
  end
end
