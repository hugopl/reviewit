class LoggedGit < Git
  def initialize
    @command_log = StringIO.new
  end

  def command_log
    @command_log.string
  end

  def call(command)
    @command_log.puts "$ #{command}"
    res = `cd #{@dir} && #{command} 2>&1`.strip
    @command_log.puts(res) unless res.empty?
    $?.success?
  end
end
