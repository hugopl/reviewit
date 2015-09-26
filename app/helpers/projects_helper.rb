module ProjectsHelper
  def full_setup_url
    port = [80, 443].include?(request.port) ? '' : ":#{request.port}"
    is_ssl = request.ssl?
    "http#{is_ssl ? 's' : ''}://#{request.host}#{port}/api/projects/#{@project.id}/setup"
  end

  def merge_request_count(project)
    count = project.merge_requests.pending.count
    return 'No open merge requests' if count.zero?
    pluralize(count, 'merge request pending', 'merge requests pending')
  end

  def projects_mr_chart_data(project)
    mrs = project.merge_requests.group("strftime('%Y-%m-%d', created_at)").where('created_at > ?', 20.days.ago).count
    last = nil
    mrs = mrs.inject({}) do |memo, (date, count)|
      year, month, day = date.split('-').map(&:to_i)

      if last
        (day - (last + 1)).times do |i|
          memo["#{year}-#{month}-#{last + i}"] = 0
        end
      end
      memo["#{year}-#{month}-#{day}"] = count
      last = day
      memo
    end
    {
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Merge requests creation per day (last 20 days)'
      },
      xAxis: {
        categories: mrs.keys,
        labels: {
          rotation: -45
        }
      },
      yAxis: {
        title: {
          text: 'Merge requests created'
        },
        min: 0
      },
      legend: {
        enabled: true
      },
      tooltip: {
        pointFormat: '{point.y} MRs'
      },
      series: [{
        name: 'Num MRs created',
        data: mrs.values
      }]
    }.to_json.html_safe
  end
end
