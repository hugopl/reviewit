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
    $("input.trigger-ci").on('click', function(event) {
        trigger_ci(event);
    });
    if ($('textarea').length > 0)
        new_editor($('textarea').get(0), false);
    toogle_merge_requests();
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

function trigger_ci(event) {
    base_url = event.target.form.action;
    Turbolinks.visit(base_url + '/trigger_ci')
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

function new_editor(elem, autofocus) {
    var editor = new SimpleMDE({ element: elem,
                                 status: false,
                                 indentWithTabs: false,
                                 autofocus: (typeof(autofocus) === 'undefined' ? true : autofocus),
                                 spellChecker: false});
    editor.render();
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
            + "<div class='comment-box'>"
            + "<textarea placeholder='Leave a comment' name='comments[" + location + "]'></textarea>"
            + "</div>"
            + "<input type='button' class=reject onclick='hide_comment_box(this);' value=Cancel>"
            + "</td></tr>";
    $(html).insertAfter(tr);
    var textArea = $(tr.nextSibling).find('textarea').get(0);
    new_editor(textArea);
};

function hide_comment_box(cancelLink) {
    var tr = cancelLink.parentElement.parentElement;
    tr.previousSibling.dataset.expanded = false;
    $(tr).remove();
}

function toogle_merge_requests(){
    $('.deleted ~ .code-review-container').slideUp(0)

    $('.toggle-file-btn').click(function(event) {
        var target = $(event.target);
        var container = target.parents('.code-review-item').find('.code-review-container');
        if(target.text() === 'Hide') {
            container.slideUp();
            target.text('Show');
        } else {
            container.slideDown();
            target.text('Hide');
        }
    })
}

