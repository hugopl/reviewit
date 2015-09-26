require 'test_helper'

class DiffTest < ActiveSupport::TestCase
  def setup
    skip('Theses tests needs reviewit git history') unless git_available?
  end

  def test_diff_subject_and_message
    diff = Diff.new(git_diff('70c5073e4b45bb276142497e2a50c754a8d7d32b'))
    diff.subject.must_equal "If there's no one interested, don't send an email."
    diff.commit_message.must_equal "Otherwise the thing brokens silently, presenting a white page to\n" \
                                   "the helpless commenter.\n" \
                                   "\n" \
                                   "This bug would cease to be noticed as soon as some other person\n" \
                                   'commented on the merge request.'
    # Multiline subject
    diff = Diff.new(git_diff('60ec5b8cfc7bf2b22e4af9f04659de6b28aea364'))
    diff.subject.must_equal "- API moved to it's own namespace. - Butons aren't links,they are now real buttons. - " \
                            "A lot of other things I don't really remember."
  end

  def test_removed_and_added_files
    diff = Diff.new(git_diff('e1bb11079d9437ccffc87d4406b2ccc3cbeacab4'))
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
    data = "From d7fbe303a4ea09d9e79c5b68d82e7c75d40a97d7 Mon Sep 17 00:00:00 2001\n" \
           "From: Hugo Parente Lima <hugo.pl@gmail.com>\n" \
           "Date: Sat, 26 Sep 2015 15:04:07 -0300\n" \
           "Subject: foo\n" \
           "\n" \
           "---\n" \
           " Foo | 0\n" \
           " 1 file changed, 0 insertions(+), 0 deletions(-)\n" \
           " create mode 100644 Foo\n" \
           "\n" \
           "diff --git a/Foo b/Foo\n" \
           "new file mode 100644\n" \
           "index 0000000..e69de29\n" \
           "-- \n" \
           "2.5.3\n"
    diff = Diff.new(data)
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :new?
    diff.files['Foo'].changes.must_be :empty?
    diff.files['Foo'].new_chmod.must_equal '100644'
  end

  def test_remove_empty_file
    data = "From d7fbe303a4ea09d9e79c5b68d82e7c75d40a97d7 Mon Sep 17 00:00:00 2001\n" \
           "From: Hugo Parente Lima <hugo.pl@gmail.com>\n" \
           "Date: Sat, 26 Sep 2015 15:04:07 -0300\n" \
           "Subject: foo\n" \
           "\n" \
           "---\n" \
           " Foo | 0\n" \
           " 1 file changed, 0 insertions(+), 0 deletions(-)\n" \
           " delete mode 100644 Foo\n" \
           "\n" \
           "diff --git a/Foo b/Foo\n" \
           "deleted file mode 100644\n" \
           "index e69de29..0000000\n" \
           "-- \n" \
           "2.5.3\n"
    diff = Diff.new(data)
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :deleted?
    diff.files['Foo'].changes.must_be :empty?
  end

  def test_chmod_change
    data = "From e48934ec000e477e8394c699942b390919548c12 Mon Sep 17 00:00:00 2001\n" \
           "From: Hugo Parente Lima <hugo.pl@gmail.com>\n" \
           "Date: Sat, 26 Sep 2015 15:15:55 -0300\n" \
           "Subject: foo\n" \
           "\n" \
           "---\n" \
           " Foo | 0\n" \
           " 1 file changed, 0 insertions(+), 0 deletions(-)\n" \
           " mode change 100644 => 100755 Foo\n" \
           "\n" \
           "diff --git a/Foo b/Foo\n" \
           "old mode 100644\n" \
           "new mode 100755\n" \
           "diff --git a/Bar b/Bar\n" \
           "old mode 100644\n" \
           "new mode 100755\n" \
           "-- \n" \
           "2.5.3\n"
    diff = Diff.new(data)
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
    data = "From e48934ec000e477e8394c699942b390919548c12 Mon Sep 17 00:00:00 2001\n" \
           "From: Hugo Parente Lima <hugo.pl@gmail.com>\n" \
           "Date: Sat, 26 Sep 2015 15:15:55 -0300\n" \
           "Subject: foo\n" \
           "\n" \
           "---\n" \
           " Foo | 0\n" \
           " 1 file changed, 0 insertions(+), 0 deletions(-)\n" \
           " mode change 100644 => 100755 Foo\n" \
           "\n" \
           "diff --git a/Foo b/Foo\n" \
           "old mode 100644\n" \
           "new mode 100755\n" \
           "index e69de29..c09fc3c\n" \
           "--- a/Foo\n" \
           "+++ b/Foo\n" \
           "@@ -0,0 +1 @@\n" \
           "+oi\n" \
           "-- \n" \
           "2.5.3\n"
    diff = Diff.new(data)
    diff.files.count.must_equal 1
    diff.files['Foo'].must_be :chmod_changed?
    diff.files['Foo'].changes.must_equal ['@@ -0,0 +1 @@', '+oi']
  end

  def test_moved_files
    diff = Diff.new(git_diff('2602550bfd82541798b5dfae6cb200a6014130b7'))
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
    diff = Diff.new(git_diff('2c28a55a0a1f954b183876111a26e25811c7017c'))
    diff.files.values.map(&:name).must_equal %w(app/assets/images/logo.png
                                                app/assets/images/logo.svg
                                                app/assets/stylesheets/devise.css.scss
                                                app/views/layouts/devise/sessions.html.erb)
    logo = diff.files['app/assets/images/logo.png']
    logo.must_be :new?
    logo.must_be :binary?
    logo.changes.must_be :empty?
  end

  def test_line_index
    diff = Diff.new(git_diff('e80b878ce3a54959e098ed7fe822a2f0292a3737'))
    diff.files['app/assets/javascripts/highcharts.js'].index.must_equal 13
    diff.files['app/helpers/projects_helper.rb'].index.must_equal 317
    diff.files['app/views/projects/show.html.erb'].index.must_equal 372
  end
end
