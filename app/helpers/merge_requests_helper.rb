module MergeRequestsHelper
  def patches
    @patches ||= @mr.patches
  end

  def patch_name(patch)
    i = @mr.patches.index(patch) + 1
    patch.description.blank? ? "#{i.ordinalize} version" : patch.description
  end

  def patch_linter_status(patch)
    content_tag(:span, '', class: "fa #{patch.linter_ok? ? 'fa-check ok' : 'fa-remove fail'}")
  end

  def merge_request_pending_since(mr)
    last_patch = mr.patch
    return if last_patch.nil?
    time = last_patch.updated_at
    last_comment = last_patch.comments.order('id DESC').limit(1).first
    time = last_comment.created_at if last_comment
    time = distance_of_time_in_words(Time.now, time)
    "pending for #{time}"
  end

  def patch_ci_icon(patch, only_cached = nil)
    if patch.pass?
      content_tag(:i, '', class: 'tipped fa fa-check ok', 'data-tip' => 'CI passed')
    elsif patch.canceled?
      content_tag(:i, '', class: 'tipped fa fa-ban', 'data-tip' => 'CI canceled')
    elsif only_cached && patch.failed?
      content_tag(:i, '', class: 'tipped fa fa-remove fail', 'data-tip' => 'CI failed')
    elsif only_cached
      return ''
    elsif @mr.nil? || !patch.project.gitlab_ci?
      content_tag(:i, '', class: 'tipped fa fa-ban', 'data-tip' => 'CI not available.')
    else
      content_tag(:i, '', class: 'tipped fa fa-refresh fa-spin',
                          'data-ci-status-url' => ci_status_project_merge_request_path(@project, @mr,
                                                                                       format: :json,
                                                                                       version: patch.version))
    end
  end

  def diff_file_status(file)
    flags = {}
    if file.new?
      flags['new'] = 'new'
      flags['chmod-changed'] = "chmod #{file.new_chmod}"
    elsif file.deleted?
      flags['deleted'] = 'deleted'
    elsif file.renamed?
      flags['renamed'] = "renamed #{file.similarity}"
    elsif file.chmod_changed?
      flags['chmod-changed'] = "chmod change: #{file.old_chmod} → #{file.new_chmod}"
    end

    flags.map do |flag, label|
      content_tag(:span, label, class: "flag #{flag}")
    end.join.html_safe
  end

  def summary_addons(patch)
    addons = patch.project.summary_addons
    return if addons.nil?
    addons.each_line do |line|
      label, template = line.split(':', 2)
      template = parse_addons_template(template, patch)
      yield label, template
    end
  end

  private

  def parse_addons_template(template, patch)
    template.gsub!('#{mr_id}', patch.merge_request.id.to_s)
    template.gsub!('#{mr_version}', patch.version.to_s)
  end
end
