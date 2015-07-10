window.projects = function() {
    var tag = $('#project_users');
    if (!tag.length)
        return;

    var users = tag[0].dataset.users.split('|');
    var myself = tag[0].dataset.myself;
    var before_add = function(event, ui) {
        return users.indexOf(ui.tagLabel) !== -1;
    };
    var before_remove = function(event, ui) {
        var its_me = ui.tagLabel === myself;
        if (its_me)
            alert('You need to participate on your own project.');
        return !its_me;
    };
    return tag.tagit({
                         fieldName: 'project[users][]',
                         availableTags: users,
                         autocomplete: {
                             delay: 0,
                             minLength: 1
                         },
                         allowDuplicates: false,
                         removeConfirmation: true,
                         beforeTagAdded: before_add,
                         beforeTagRemoved: before_remove,
                         placeholderText: 'Type the user names'
                     });
};
