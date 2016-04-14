require 'test_helper'

class DiffTest < ActiveSupport::TestCase
  def test_diff_subject_and_message
    diff = Diff.new(patch('diff_subject_and_message_1'))
    diff.subject.must_equal "If there's no one interested, don't send an email."
    diff.commit_message.must_equal "Otherwise the thing brokens silently, presenting a white page to\n" \
                                   "the helpless commenter.\n" \
                                   "\n" \
                                   "This bug would cease to be noticed as soon as some other person\n" \
                                   'commented on the merge request.'
    # Multiline subject
    diff = Diff.new(patch('diff_subject_and_message_2'))
    diff.subject.must_equal "- API moved to it's own namespace. - Butons aren't links, they are now real buttons. - " \
                            "A lot of other things I don't really remember."
  end

  def test_removed_and_added_files
    diff = Diff.new(patch('removed_and_added_files'))
    diff.files.values.map(&:name).must_equal %w(README.md README.rdoc)

    readme_md = diff.files['README.md']
    readme_md.must_be :new?
    readme_md.changes.first.must_equal '@@ -0,0 +1,44 @@'
    readme_md.changes.last.must_equal '+3. Way to review resolution of merge conflicts.'

    readme_rdoc = diff.files['README.rdoc']
    readme_rdoc.must_be :deleted?

    readme_rdoc.changes.first.must_equal '@@ -1,28 +0,0 @@'
    readme_rdoc.changes.last.must_equal '-<tt>rake doc:app</tt>.'
  end

  def test_add_empty_file
    diff = Diff.new(patch('add_empty_file'))
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :new?
    diff.files['Foo'].changes.must_be :empty?
    diff.files['Foo'].new_chmod.must_equal '100644'
  end

  def test_remove_empty_file
    diff = Diff.new(patch('remove_empty_file'))
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :deleted?
    diff.files['Foo'].changes.must_be :empty?
  end

  def test_chmod_change
    diff = Diff.new(patch('chmod_change'))
    diff.files.count.must_equal 2
    diff.files['Foo'].must_be :chmod_changed?
    diff.files['Foo'].changes.must_be :empty?
    diff.files['Foo'].old_chmod.must_equal '100644'
    diff.files['Foo'].new_chmod.must_equal '100755'
    diff.files['Bar'].must_be :chmod_changed?
    diff.files['Bar'].changes.must_be :empty?
    diff.files['Bar'].old_chmod.must_equal '100644'
    diff.files['Bar'].new_chmod.must_equal '100755'
  end

  def test_chmod_change_with_contents
    diff = Diff.new(patch('chmod_change_with_contents'))
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :chmod_changed?
    diff.files['Foo'].changes.must_equal ['@@ -0,0 +1 @@', '+oi']
  end

  def test_moved_files
    diff = Diff.new(patch('moved_files'))
    diff.files.values.map(&:name).must_equal %w(app/assets/fonts/FontAwesome.otf
                                                app/assets/fonts/fontawesome-webfont.eot
                                                app/assets/fonts/fontawesome-webfont.svg
                                                app/assets/fonts/fontawesome-webfont.ttf
                                                app/assets/fonts/fontawesome-webfont.woff
                                                app/assets/stylesheets/font-awesome.css.scss
                                                config/environments/production.rb
                                                config/initializers/assets.rb)
    font1 = diff.files['app/assets/fonts/FontAwesome.otf']
    font1.must_be :renamed?
    font1.renamed_from.must_equal 'app/assets/stylesheets/fonts/FontAwesome.otf'
  end

  def test_binary_files
    diff = Diff.new(patch('binary_files'))
    diff.files.values.map(&:name).must_equal %w(app/assets/images/logo.png
                                                app/views/layouts/devise/sessions.html.erb)
    logo = diff.files['app/assets/images/logo.png']
    logo.must_be :new?
    logo.must_be :binary?
    logo.changes.must_equal ['This is a binary file, code to view it here is not done yet :-(']
  end

  def test_line_index
    diff = Diff.new(patch('line_index'))
    diff.files['app/helpers/projects_helper.rb'].index.must_equal 11
    diff.files['app/views/projects/show.html.erb'].index.must_equal 66
  end
end
