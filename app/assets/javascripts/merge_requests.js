function merge_requests() {
    return $("td > div.add-comment").on('click', function(event) {
        return show_comment_box(event.target.parentElement.parentElement);
    });
};

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
    return $(tr.nextSibling).find('textarea').focus();
};

function hide_comment_box(cancelLink) {
    var tr = cancelLink.parentElement.parentElement;
    tr.previousSibling.dataset.expanded = false;
    return $(tr).remove();
};

function update_ci_status(data) {
    var ciStatus = $('#ci_status');
    ciStatus.removeClass('fa-refresh fa-spin');
    switch (data['status']) {
    case 'failed':
        ciStatus.addClass('fa-remove fail');
        break;
    case 'success':
        ciStatus.addClass('fa-check ok');
        break;
    case 'unknown':
        ciStatus.addClass('fa-question');
        break;
    default:
        ciStatus.addClass('fa-gears');
    }
    return ciStatus.on('click', function(event) {
        if (data['url'])
            return window.open(data['url'], data['url']);
        else
            return alert('Unable to connect to CI.');
    });
};

