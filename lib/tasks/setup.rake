require 'fileutils'

DATABASE_YML =<<eos
development: &development
  adapter: sqlite3
  pool: 5
  timeout: 5000
  database: db/development.sqlite3
test:
  <<: *development
  database: db/test.sqlite3
eos

desc 'Setup r-me for development'
task :setup do
  unless File.exist? 'config/database.yml'
    File.open('config/database.yml', 'w') do |file|
      file.write DATABASE_YML
    end
  end
  FileUtils.rm_f 'db/development.sqlite3'
  Rake::Task['db:migrate'].invoke
  Rake::Task['sample'].invoke
end
