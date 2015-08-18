require 'test_helper'
require 'rails/performance_test_help'

class MergeRequestIndexTest < ActionDispatch::PerformanceTest
  self.profile_options = { runs: 1, metrics: %i(wall_time memory objects),
                           output: 'tmp/performance', formats: [:flat] }

  setup do
    user = create(:user)
    project = create(:project, users: [user])
    25.times do
      mr = create(:merge_request, project: project)
      create(:patch, merge_request: mr)
    end
    login_as(user, scope: :user)
  end

  test 'index' do
    get "/projects/#{Project.first.id}/merge_requests"
  end
end
