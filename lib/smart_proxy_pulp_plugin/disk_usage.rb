module PulpProxy
  class DiskUsage
    include ::Proxy::Util
    SIZE = { :kilobyte => 1_024, :megabyte => 1_048_576, :gigabyte => 1_073_741_824, :terabyte => 1_099_511_627_776 }

    attr_reader :path, :stat, :size

    def initialize(opts ={})
      @path = opts[:path] || raise(::Proxy::Error::ConfigurationError, 'Unable to continue - must provide a path.')
      @size = SIZE[opts[:size]] || SIZE[:gigabyte]
      find_df
      get_stat
    end

    def to_json
      data.to_json
    end

    def data
      stat.merge({ :path => path, :size => SIZE.key(size) })
    end

    private

    attr_reader :command_path

    def find_df
      @command_path = which('df') || raise(::Proxy::Error::ConfigurationError, 'df command was not found unable to retrieve usage information.')
    end

    def get_stat
      raw = Open3::popen3("#{command_path} -B#{size} #{path}") do |stdin, stdout, stderr, thread|
        stdout.read.split("\n")
      end

      titles = raw.first.downcase.gsub('mounted on', 'mounted').split.map(&:to_sym)
      data   = raw.last.split
      @stat  ||= Hash[titles.zip(data.map { |i| i })]
    end
  end
end
