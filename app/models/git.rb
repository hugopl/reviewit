class Git
  def clone(repository, branch = 'master')
    background do
      base_dir = "#{Dir.tmpdir}/reviewit"
      project_dir_name = "#{branch}_#{SecureRandom.hex}"
      dir = "#{base_dir}/#{project_dir_name}"
      FileUtils.rm_rf dir
      FileUtils.mkdir_p dir

      @branch = branch
      @dir = base_dir
      @ready = call("git clone --branch #{branch} --depth 1 #{repository} #{project_dir_name}")
      @dir = dir

      yield(self)
      FileUtils.rm_rf(dir) if @ready
    end
  end

  attr_reader :dir, :ready
  alias_method :ready?, :ready

  def am(patch)
    contents = patch.formatted
    file = Tempfile.new('patch')
    file.puts contents
    file.close
    call("git am #{file.path}")
  end

  def push(branch, forced = nil)
    call("git push #{forced ? '-f' : ''} origin #{@branch}:#{branch}")
  end

  def rm_branch(branch)
    call("git push origin :#{branch}")
  end

  def sha1(branch = 'HEAD')
    `cd #{@dir} && git rev-parse #{branch}`.strip
  end

  protected

  def call(command)
    `cd #{@dir} && #{command} 2>&1`
    $?.success?
  end

  private

  def background
    Thread.new do
      begin
        yield
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end
end
