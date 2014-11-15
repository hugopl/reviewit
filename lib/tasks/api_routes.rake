desc 'API Routes'
task :api_routes, [] => :environment do
  Reviewit::API.routes.each do |api|
    method = api.route_method.ljust(10)
    path = api.route_path
    puts "  #{method} #{path}"
  end
end
