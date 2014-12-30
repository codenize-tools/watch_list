class WatchList::Client
  def initialize(options = {})
    @options = options
    @uptimerobot = UptimeRobot::Client.new(:apiKey => options[:apiKey])
  end

  def export(opts = {})
    exported = WatchList::Exporter.export(@uptimerobot, @options.merge(opts))
    WatchList::DSL.convert(exported, @options.merge(opts))
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    dsl = load_file(file)
    # XXX:
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        WatchList::DSL.parse(f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      WatchList::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
