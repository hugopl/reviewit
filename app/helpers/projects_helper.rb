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
    period = 20
    first_day = period.days.ago
    mrs = project.merge_requests.group('DATE(created_at)').where('created_at > ?', first_day).count

    day = first_day
    period.times do
      day = day.tomorrow.to_date
      next if mrs.key?(day)
      mrs[day] = 0
    end

    dates = []
    counts = []
    mrs.sort.each do |date, count|
      dates << format('%i-%02i-%02i', date.year, date.month, date.day)
      counts << count
    end

    {
      chart: {
        type: 'spline'
      },
      title: {
        text: "Merge requests creation per day (last #{period} days)"
      },
      xAxis: {
        categories: dates,
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
        data: counts
      }]
    }.to_json.html_safe
  end

  def projects_reviews_chart_data(project)
    query = project.merge_requests.joins(:reviewer).limit(100).order('merge_requests.created_at DESC')
                   .select('users.name').to_sql
    db = ActiveRecord::Base.connection
    data = db.execute("SELECT name, COUNT(name) AS y FROM (#{query}) AS data GROUP BY name").to_a

    data.map! do |entry|
      if entry['name'] == current_user.name
        entry['sliced'] = true
        entry['selected'] = true
      end
      entry['y'] = entry['y'].to_i
      entry
    end

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
