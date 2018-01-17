class Git
  def initialize(repository)
    @repository = repository
    @log = StringIO.new
  end

  attr_reader :dir

  def init
    create_directories
    FileUtils.mkdir_p(@dir) || fail("Error creating directory #{@dir}")
    call('git init .')
    call("git remote add origin #{@repository}")
  end

  def clone(branch)
    @branch = branch
    project_dir_name = create_directories
    call("git clone --branch #{branch} --depth 1 #{@repository} #{project_dir_name}", @base_dir)
  end

  def cleanup
    FileUtils.rm_rf(@dir)
  end

  def am(patch)
    contents = patch.diff(stamp: true)
    file = Tempfile.new('patch')
    file.puts(contents)
    file.close
    call("git am -k #{file.path}")
  end

  def push(branch, forced: false)
    call("git push #{forced ? '-f' : ''} origin refs/heads/#{@branch}:#{branch}")
  end

  def rm_branches(branches)
    branches_to_remove = branches.map { |branch| ":refs/heads/#{branch}" }.join(' ')
    call("git push origin #{branches_to_remove}")
  end

  def rm_branch(branch)
    call("git push origin :refs/heads/#{branch}")
  end

  def sha1(branch = 'HEAD')
    `cd #{@dir} && git rev-parse #{branch}`.strip
  end

  def log
    @log.string
  end

  private

  def create_directories
    @base_dir = "#{Dir.tmpdir}/reviewit"
    project_dir_name = SecureRandom.hex.to_s
    @dir = "#{@base_dir}/#{project_dir_name}"

    FileUtils.mkdir_p(@base_dir) || fail("Error creating directory #{@base_dir}")
    project_dir_name
  end

  def call(command, directory = @dir)
    @log.puts "$ #{command}"
    res = `cd #{directory} && #{command} 2>&1`.strip
    @log.puts(res) unless res.empty?
    $?.success?
  end
end
