describe Diff do
  it 'detects subject message' do
    diff = Diff.new(patch('diff_subject_and_message_1'))
    expect(diff.subject).to eq("If there's no one interested, don't send an email.")
    expect(diff.commit_message).to eq("Otherwise the thing brokens silently, presenting a white page to\n" \
                                      "the helpless commenter.\n" \
                                      "\n" \
                                      "This bug would cease to be noticed as soon as some other person\n" \
                                      "commented on the merge request.\n\n")
    # Multiline subject
    diff = Diff.new(patch('diff_subject_and_message_2'))
    expect(diff.subject).to eq("- API moved to it's own namespace. - Butons aren't links, they are now real buttons. - " \
                               "A lot of other things I don't really remember.")
  end

  it 'detects removed and added files' do
    diff = Diff.new(patch('removed_and_added_files'))
    expect(diff.files.values.map(&:name)).to eq(%w(README.md README.rdoc))

    readme_md = diff.files['README.md']
    expect(readme_md).to be_new
    expect(readme_md.changes.first).to eq('@@ -0,0 +1,44 @@')
    expect(readme_md.changes.last).to eq('+3. Way to review resolution of merge conflicts.')

    readme_rdoc = diff.files['README.rdoc']
    expect(readme_rdoc).to be_deleted

    expect(readme_rdoc.changes.first).to eq('@@ -1,28 +0,0 @@')
    expect(readme_rdoc.changes.last).to eq('-<tt>rake doc:app</tt>.')
  end

  it 'detects empty file aditions' do
    diff = Diff.new(patch('add_empty_file'))
    expect(diff.files.count).to eq(1)
    expect(diff.files['Foo']).to be_new
    expect(diff.files['Foo'].changes).to be_empty
    expect(diff.files['Foo'].new_chmod).to eq('100644')
  end

  it 'detects empty file removals' do
    diff = Diff.new(patch('remove_empty_file'))
    expect(diff.files.count).to eq(1)
    expect(diff.files['Foo']).to be_deleted
    expect(diff.files['Foo'].changes).to be_empty
  end

  it 'detects chmod changes' do
    diff = Diff.new(patch('chmod_change'))
    expect(diff.files.count).to eq(2)
    expect(diff.files['Foo']).to be_chmod_changed
    expect(diff.files['Foo'].changes).to be_empty
    expect(diff.files['Foo'].old_chmod).to eq('100644')
    expect(diff.files['Foo'].new_chmod).to eq('100755')
    expect(diff.files['Bar']).to be_chmod_changed
    expect(diff.files['Bar'].changes).to be_empty
    expect(diff.files['Bar'].old_chmod).to eq('100644')
    expect(diff.files['Bar'].new_chmod).to eq('100755')
  end

  it 'detects chmod changes with contents' do
    diff = Diff.new(patch('chmod_change_with_contents'))
    expect(diff.files.count).to eq(1)
    expect(diff.files['Foo']).to be_chmod_changed
    expect(diff.files['Foo'].changes).to eq(['@@ -0,0 +1 @@', '+oi'])
  end

  it 'detects file moves' do
    diff = Diff.new(patch('moved_files'))
    expect(diff.files.values.map(&:name)).to eq(%w(app/assets/fonts/FontAwesome.otf
                                                   app/assets/fonts/fontawesome-webfont.eot
                                                   app/assets/fonts/fontawesome-webfont.svg
                                                   app/assets/fonts/fontawesome-webfont.ttf
                                                   app/assets/fonts/fontawesome-webfont.woff
                                                   app/assets/stylesheets/font-awesome.css.scss
                                                   config/environments/production.rb
                                                   config/initializers/assets.rb))
    font1 = diff.files['app/assets/fonts/FontAwesome.otf']
    expect(font1).to be_renamed
    expect(font1.renamed_from).to eq('app/assets/stylesheets/fonts/FontAwesome.otf')
  end

  it 'detect binary files' do
    diff = Diff.new(patch('binary_files'))
    expect(diff.files.values.map(&:name)).to eq(%w(app/assets/images/logo.png app/views/layouts/devise/sessions.html.erb))
    logo = diff.files['app/assets/images/logo.png']
    expect(logo).to be_new
    expect(logo).to be_binary
    expect(logo.size).to eq(2097)
    expect(logo.changes.encoding.name).to eq('ASCII-8BIT')
    expect(logo.changes.size).to eq(2097)
  end

  it 'detects file indexes' do
    diff = Diff.new(patch('line_index'))
    expect(diff.files['app/helpers/projects_helper.rb'].index).to eq(11)
    expect(diff.files['app/views/projects/show.html.erb'].index).to eq(66)
  end
end
