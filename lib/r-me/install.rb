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
  puts 'Checking r-me gem...'
  `gem list r-me -i`
  $?.success?
end

def install_rme_gem
  gem_file = "/tmp/#{File.basename($gem_url)}"
  puts 'Downloading r-me gem...'
  File.open(gem_file, 'wb') do |f|
    f.write(Net::HTTP.get(URI($gem_url)))
  end

  puts 'Installing r-me gem...'
  `gem install #{gem_file}`
  abort 'Failed to install r-me gem' unless $?.success?
end

def configure_git
  puts 'Configuring git...'
  `git config --local rme.projectid #{$project_id}`
  `git config --local rme.baseurl #{$base_url}` if $?.success?
  `git config --local rme.apitoken #{$api_token}` if $?.success?
  abort 'Error configuring git for rme.' unless $?.success?
end

puts "r-me command line interface installer for #{$project_name}\n"
install_rme_gem unless check_rme_gem

configure_git
puts 'All done, type rme --help for more info.'
