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

  def projects_reviews_chart_data(project)
    query = project.merge_requests.joins(:reviewer).limit(100).order('merge_requests.created_at DESC')
                   .select('users.name').to_sql
    db = ActiveRecord::Base.connection
    data = db.execute("SELECT name, COUNT(name) AS y FROM (#{query}) GROUP BY name")
    total = data.inject(0) { |a, e| a + e['y'].to_i }

    {
      chart: {
        plotBackgroundColor: nil,
        plotBorderWidth: nil,
        plotShadow: false,
        type: 'pie'
      },
      title: {
        text: "Last #{total} merge requests reviews"
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b>: {point.percentage:.1f} %'
          }
        }
      },
      series: [{
        name: 'Reviews',
        data: data
      }]
    }.to_json.html_safe
  end
end
