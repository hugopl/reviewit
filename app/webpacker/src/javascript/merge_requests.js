import EasyMDE from 'easymde'

export default function merge_requests() {
    $(".patch-history input[type=radio]").on('change', function(event) {
        handle_history_radios(event.target);
    });
    $(".js-add-comment").on('click', function(event) {
        show_comment_box(event);
    });
    $("#patch-history-submit").on('click', function(event) {
        request_patch_diff(event);
    });
    $(".js-trigger-ci").on('click', function(event) {
        trigger_ci(event);
    });
    $('.js-toggle-diff').on('click', function(event) {
        toggle(event.target);
    });
    $('#accept').on('click', function(event) { showSubmitModal('accept'); });
    $('#abandon').on('click', function(event) { showSubmitModal('abandon'); });
    $('#like').on('click', function(event) { like(event); });
    $('#accept-model-button').on('mouseover', function(event) { $('.js-tada').transition('tada'); });
    if ($('textarea').length > 0)
        new_editor($('textarea').get(0), false);

    toogle_merge_requests();
}

function showSubmitModal(action) {
    $('#' + action + '-modal').modal({ onApprove: function() {
        $('#mr_action').val(action);
        $('#mr-form').submit();
        return false;
    }}).modal('show')
}

function like(event) {
    $('#mr_action').val('like');
    $('#mr-form').submit();
    return false;
}

function request_patch_diff(event) {
    var form = $(event.target.form)
    var query = '?';
    var from = form.find('input[name=from]:checked').val();
    if (from !== '0')
        query += 'from=' + from + '&';
    var to = form.find('input[name=to]:checked').val();
    query += 'to=' + to;
    Turbolinks.visit(query);
}

function trigger_ci(event) {
    event.preventDefault();
    var base_url = $('#mr-form')[0].action;
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

    var radios = $(".patch-history input[type=radio]");
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
    var editor = new EasyMDE({ element: elem,
                               status: false,
                               indentWithTabs: false,
                               autofocus: (typeof(autofocus) === 'undefined' ? true : autofocus),
                               spellChecker: false});
    editor.render();
}

function show_comment_box(event) {
    var tr = $(event.target).parents('tr')[0];
    event.preventDefault();

    if ($(tr).next().hasClass('comments')) {
        tr = $(tr).next()[0];
    }
    if (tr.dataset.expanded === 'true') {
        $(tr.nextSibling).find('textarea').focus();
        return;
    }
    tr.dataset.expanded = true;
    var location = tr.dataset.location;

    var blockerHTML = '';
    if (!isAuthor && isOpenMR) {
        var blocker = tr.dataset.blocker === '';
        var checkboxText = blocker ? 'Issue solved' : 'Blocker issue?';
        var blockerVar = blocker ? 'solved' : 'blockers';
        var blockerChecked = blocker ? '' : ' checked';
        blockerHTML = "<div class=\"ui checkbox\">"
            + "<input id=blocker_" + location + " type=checkbox value=1" + blockerChecked + " name='" + blockerVar + "[" + location + "]'>"
            + "<label for=blocker_" + location + ">" + checkboxText + "</label>"
    }

    var html = "<tr><td colspan='3' class='add-comment'>"
            + "<div class='editor-box'>"
            + "<textarea placeholder='Leave a comment' name='comments[" + location + "]'></textarea>"
            + "</div>"
            + "<div class='comment-controls'>"
            + "<button type=\"button\" class=\"js-reject ui tiny button right floated\">Cancel</button>"
            + blockerHTML
            + "</div>"
            + "</td></tr>";
    $(html).insertAfter(tr);
    $(tr.nextSibling).find('.js-reject').on('click', function(event) {
        hide_comment_box(event.target);
    });

    var textArea = $(tr.nextSibling).find('textarea').get(0);
    new_editor(textArea);
};

function hide_comment_box(cancelLink) {
    var tr = cancelLink.parentElement.parentElement.parentElement;
    tr.previousSibling.dataset.expanded = false;
    $(tr).remove();
}

function toogle_merge_requests() {
    $('.js-deleted-file').prev('.js-toggle-diff').each(function() { toggle(this) });
}

function toggle(target) {
  var diffView = $(target.parentElement.nextElementSibling);
  var hidden = target.dataset.hidden;

  if (hidden == 'true') {
      target.dataset.hidden = false;
      diffView.slideDown();
      $(target).css('transform', 'none');
  } else {
      target.dataset.hidden = true;
      diffView.slideUp();
      $(target).css('transform', 'rotate(270deg)');
  }
}
