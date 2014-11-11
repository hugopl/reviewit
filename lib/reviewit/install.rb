require 'net/http'

# $base_url
# $api_token
# $project_name
# $project_id
# $gem_url

def puts text
  STDOUT.puts "\033[0;32m#{text}\033[0m"
end

def check_rme_gem
  puts 'Checking reviewit gem...'
  `gem list reviewit -i`
  $?.success?
end

def install_rme_gem
  gem_file = "/tmp/#{File.basename($gem_url)}"
  puts 'Downloading reviewit gem...'
  File.open(gem_file, 'wb') do |f|
    f.write(Net::HTTP.get(URI($gem_url)))
  end

  puts 'Installing reviewit gem...'
  abort 'Failed to install reviewit gem' unless system("gem install #{gem_file}")
end

def check_git_repository
  # TODO: Check if the local git repository is the same referenced by
  #       rme, check this using git remote show and git remote show -n
end

def configure_git
  puts 'Configuring git...'
  `git config --local reviewit.projectid #{$project_id}`
  `git config --local reviewit.baseurl #{$base_url}` if $?.success?
  `git config --local reviewit.apitoken #{$api_token}` if $?.success?
  abort 'Error configuring git for rme.' unless $?.success?
end

puts "reviewit command line interface installer for #{$project_name}\n"
install_rme_gem unless check_rme_gem

check_git_repository
configure_git
puts 'All done, type review --help to know what you can do.'
