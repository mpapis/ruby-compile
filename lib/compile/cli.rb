require "command-designer"
require "remote-exec"

module Compile
  class Cli < CommandDesigner::Dsl

    def initialize(args)
      @args = args
      parse_args
      super([:first, nil, :last])
      yield self if block_given?
    end

    def parse_args
      iterator = @args.each
      while param = iterator.next
        case param
        when '-r'
          self.server = iterator.next
        when /^ruby-.*/
          @ruby_version = param
        else
          $stderr.puts "unknown parameter #{param.inspect}"
          exit 1
        end
      end
    rescue StopIteration
    end

    def server=(param)
      _, user, host = param.match(/((.*)@)?(.*)/)
      @server = RemoteExec::Ssh.new(host, user)
    end

    def server
      @server ||= RemoteExec::Local.new
    end

    def execute
      puts "ruby: #{@ruby_version.inspect} server: #{server.inspect}"
      run(:curl, "-LO", "http://ftp.ruby-lang.org/pub/ruby/#{@ruby_version}.tar.bz2") &&
      run(:mkdir, "src/") &&
      command_prefix(:cd, "src/") do
        run(:tar, "-xjf" ,"#{@ruby_version}.tar.bz2", "--strip 1")
        run("./configure", "--prefix", @ruby_version)
        run(:make, "install")
      end
    end

    def run(*params)
      cmd = command(*params)
      puts "Executing: #{cmd}"
      status = server.execute(cmd)
      if status == 0
      then puts "Success"
      else puts "Failed(#{status})"
      end
      return status == 0
    end

    def command_prefix(code, *params, &block)
      options = Hash === params.last ? params.pop : {}
      options[:separator] ||= options[:s] || "&&"
      cmd_prefix = command(code, *params)
      local_filter(
        Proc.new { |cmd|
          "#{cmd_prefix} #{options[:separator]} #{cmd}"
        },
        &block
      )
    end

  end
end
