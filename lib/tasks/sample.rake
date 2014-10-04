desc 'Populate the database with sample data'
task :sample, [] => :environment do
  ActiveRecord::Base.transaction do
    u = User.new
    u.name = 'hugopl'
    u.password = 'tijolo22'
    u.email = 'hugo@localhost.localhost'
    u.save!

    p = Project.new
    p.name = 'Hello World'
    p.repository = '/tmp/helloworld.git'
    p.users << u
    p.save!
  end
end
