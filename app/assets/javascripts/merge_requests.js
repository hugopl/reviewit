function merge_requests() {
    $(".patch-history input[type=radio]").on('change', function(event) {
        handle_history_radios(event.target);
    });
    $("td > div.add-comment").on('click', function(event) {
        show_comment_box(event.target.parentElement.parentElement);
    });
    $(".patch-history-submit input").on('click', function(event) {
        request_patch_diff();
    });
    $("i[data-ci-status-url]").each(function(i, elem) {
        load_ci_status(elem);
    });
}

function request_patch_diff() {
    var query = '?';
    var from = $('.patch-history input[name=from]:checked').val();
    if (from !== '0')
        query += 'from=' + from + '&';
    var to = $('.patch-history input[name=to]:checked').val();
    query += 'to=' + to;
    Turbolinks.visit(query);
}

function handle_history_radios(radio) {
    var name = radio.name;
    var value = radio.value;

    var disableTo = null;
    var disableFrom = null;
    if (name === 'from')
        disableTo = value;
    else
        disableFrom = value;

    radios = $(".patch-history input[type=radio]");
    for (var i = 0; i < radios.length; ++i) {
        var r = radios[i];
        if (disableTo !== null) {
            if (r.name === 'from')
                continue;
            r.disabled = r.value <= disableTo;
        } else if (disableFrom !== null) {
            if (r.name === 'to')
                continue;
            r.disabled = r.value >= disableFrom;
        }
    }
}

function show_comment_box(tr) {
    var extraCss = '';
    if ($(tr).next().hasClass('comment')) {
        tr = $(tr).next()[0];
        extraCss = 'reply';
    }
    if (tr.dataset.expanded === 'true') {
        $(tr.nextSibling).find('textarea').focus();
        return;
    }
    tr.dataset.expanded = true;
    var location = tr.dataset.location;
    var html = "<tr><td colspan='3' class='add-comment " + extraCss + "'>"
            + "<textarea placeholder='Leave a comment' name='comments[" + location + "]'></textarea>"
            + "<input type='button' class=reject onclick='hide_comment_box(this);' value=Cancel>"
            + "</td></tr>";
    $(html).insertAfter(tr);
    $(tr.nextSibling).find('textarea').focus();
};

function hide_comment_box(cancelLink) {
    var tr = cancelLink.parentElement.parentElement;
    tr.previousSibling.dataset.expanded = false;
    $(tr).remove();
}

function load_ci_status(elem) {
    $.ajax(elem.dataset.ciStatusUrl).done(function(result) {
        update_ci_status(elem, result['status'], result['url']);
    });
}

function update_ci_status(elem, status, url) {
    ciStatus = $(elem).removeClass('fa-refresh fa-spin');

    var ci = {
        'failed'  : ['fa-remove fail', 'CI failed'],
        'success' : ['fa-check ok', 'CI passed'],
        'unknown' : ['fa-question', 'Unknow CI status'],
        'pending' : ['fa-clock-o', 'CI pending'],
        'canceled': ['fa-ban', 'CI canceled'],
        'running' : ['fa-cog fa-spin', 'CI running']
    }

    ciStatus.addClass(ci[status][0]);
    Tipped.remove(elem);
    Tipped.create(elem, ci[status][1]);

    if (url) {
        ciStatus.addClass('ci-link');
        ciStatus.on('click', function(event) { window.open(url, url); });
    }
}

