class Git
  def clone(repository, branch)
    background do
      base_dir = "#{Dir.tmpdir}/reviewit"
      project_dir_name = "#{branch}_#{SecureRandom.hex}"
      dir = "#{base_dir}/#{project_dir_name}"
      FileUtils.rm_rf dir
      FileUtils.mkdir_p dir

      @dir = base_dir
      cloned = call("git clone --depth 1 #{repository} #{project_dir_name}")
      @dir = dir
      reseted = call("git reset --hard origin/#{branch}") if cloned
      @ready = cloned && reseted

      yield(self)
      FileUtils.rm_rf(dir) if cloned
    end
  end

  attr_reader :dir

  def ready?
    @ready
  end

  def am(patch)
    contents = patch.formatted
    file = Tempfile.new('patch')
    file.puts contents
    file.close
    call("git am #{file.path}")
  end

  def push(branch)
    call("git push origin master:#{branch}")
  end

  def rm_branch(branch)
    call("git push origin :#{branch}")
  end

  def sha1(branch = 'HEAD')
    call("git rev-parse #{branch}")
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
