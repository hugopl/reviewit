import Highcharts from 'highcharts'

var popupTimer

export default function projects() {
  renderCharts()

  $('#copy-cli-install').click(function(event) {
    event.preventDefault()
    clearTimeout(popupTimer);
    $(this).siblings('input').select();
    document.execCommand("copy");
    $(this).popup({ content  : 'Command copied!', on: 'manual', exclusive: true }).popup('show')
    delayPopup(this)
  })

  var destroyProjectBtn = $('#destroy-project-btn')
  destroyProjectBtn.click(function() {
    $('.ui.basic.modal').modal({ onApprove: function() {
      var url = "/projects/" + destroyProjectBtn.data('project-id')
      $.ajax({ url: url, method: "DELETE" }).done(function(data) {
         Turbolinks.visit('/projects')
      })
    }}).modal('show')
  })
};

function delayPopup(popup) {
  popupTimer = setTimeout(function() { $(popup).popup('hide') }, 4200);
}

function renderCharts() {
  if ($('#project-mr-chart').length === 0)
      return

  Highcharts.chart('project-mr-chart', mrChartData)
  Highcharts.chart('project-reviews-chart', reviewersChartData)
  Highcharts.chart('project-authors-chart', authorsChartData)
}
