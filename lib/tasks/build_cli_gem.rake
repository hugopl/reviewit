desc 'Build reviewit CLI gem an dput it in the public directory'
task :build_cli_gem do
  Dir.chdir('lib/reviewit') do
    system('gem build reviewit.gemspec') || fail
    FileUtils.mv(Dir.glob('reviewit-*.gem'), '../../public', verbose: true)
  end
end
