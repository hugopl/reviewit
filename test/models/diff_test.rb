    diff = Diff.new(patch('diff_subject_and_message_1'))
    diff = Diff.new(patch('diff_subject_and_message_2'))
    diff = Diff.new(patch('removed_and_added_files'))
    diff = Diff.new(patch('add_empty_file'))
    diff = Diff.new(patch('remove_empty_file'))
    diff = Diff.new(patch('chmod_change'))
    diff = Diff.new(patch('chmod_change_with_contents'))
    diff = Diff.new(patch('moved_files'))
    diff = Diff.new(patch('binary_files'))
    diff = Diff.new(patch('line_index'))
    diff.files['app/helpers/projects_helper.rb'].index.must_equal 12
    diff.files['app/views/projects/show.html.erb'].index.must_equal 67