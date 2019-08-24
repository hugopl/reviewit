module MergeRequestsHelper
  def patches
    @patches ||= @mr.patches
  end

  def patch_name(patch, version = nil)
    version ||= @mr.patches.index(patch) + 1
    patch.description.blank? ? "#{version.ordinalize} version" : "v#{version}: #{patch.description}"
  end

  def patch_linter_status(patch)
    patch.linter_ok? ? 'green check' : 'red remove'
  end

  def author_sentence(mr)
    closed_info = mr.closed? ? ", #{@mr.status} by <strong>#{@mr.reviewer.name}</strong>." : ''
    "Authored by <strong>#{mr.author.name}</strong>#{closed_info}".html_safe
  end

  def search_request?
    !params[:author].blank? || !params[:target_branch].blank? || !params[:subject].blank?
  end

  def merge_request_status_line(mr)
    time = distance_of_time_in_words(Time.now, mr.updated_at)
    mr.closed? ? "Closed #{time} ago," : "Pending for #{time}"
  end

  def large_target_branch?
    @mr.target_branch.size > 8
  end

  def target_branch_icon
    large_target_branch? ? '<i class="icon code branch grey"></i>'.html_safe : @mr.target_branch
  end

  def target_branch_label
    large_target_branch? ? @mr.target_branch : 'Target'
  end

  def should_show_patch_comment_divisor(patch, main_patch)
    return patch.comments.general.any? if patch == main_patch

    patch.comments.general.any?
  end

  def interdiff_view?
    @from.nonzero?
  end

  def diff_file_status(file)
    labels = {}
    labels[number_to_human_size(file.size)] = 'black' if file.binary? && !file.delta?

    if file.new?
      labels['new'] = 'green'
      labels["chmod #{file.new_chmod}"] = 'grey'
    elsif file.deleted?
      labels['deleted'] = 'red js-deleted-file'
    elsif file.renamed?
      labels["renamed #{file.similarity}"] = 'blue'
    elsif file.chmod_changed?
      labels["chmod change: #{file.old_chmod} → #{file.new_chmod}"] = 'teal'
    end

    # interdiff tags
    labels[file.interdiff_tag] = 'grey' if file.interdiff_tag

    labels.map do |label, css|
      content_tag(:div, label, class: "ui #{css} label tiny")
    end.join.html_safe
  end

  def target_branch_locked?
    @target_branch_locked ||= @mr.target_branch_locked?
  end

  def locked_branches
    @locked_branches ||= @project.locked_branches.includes(:who).to_a
  end

  def issue_link(issue)
    content = issue.content.truncate(120)
    options = { anchor: "comment-#{issue.id}" }
    if issue.patch_id != @mr.patch.id
      version = @mr.patch_ids.index(issue.patch_id) + 1
      options[:to] = version
      extra = " ― On #{version.ordinalize} version"
    end

    link = link_to(content, project_merge_request_path(@project, @mr, options))
    "#{link}#{extra}".html_safe
  end

  def code_comment_icon(comments)
    if comments.any?(&:blocker?)
      'icon exclamation'
    elsif comments.any?(&:solved?)
      'icon check'
    else
      'icon comments'
    end
  end

  def mr_label(mr)
    if mr.project.gitlab_ci?
      "<i class=\"#{ci_icon_css(mr.patch)} icon\"></i> #{mr.target_branch}".html_safe
    else
      mr.target_branch
    end
  end

  def code_line_type(line)
    case line[0]
    when '+' then 'add'
    when '-' then 'del'
    when '@' then 'info'
    end
  end

  def ci_icon(patch)
    return unless patch.project.gitlab_ci?

    icon = %(<i class="#{ci_icon_css(patch)} icon"></i>).html_safe
    if patch.unknown?
      icon
    else
      content_tag(:a, icon, target: "patch-#{patch.gitlab_ci_hash}",
                            href: "#{patch.project.gitlab_ci_project_url}/builds/#{patch.gitlab_ci_build}")
    end
  end

  def ci_icon_css(patch)
    case patch.gitlab_ci_status
    when 'failed' then 'red remove'
    when 'success' then 'green check'
    when 'unknown' then 'question'
    when 'pending' then 'clock'
    when 'canceled' then 'ban'
    when 'running' then 'cog spin'
    end
  end

  def status_icon(mr)
    return 'yellow lock' if target_branch_locked?

    case mr.status
    when 'integrating' then 'cog spin'
    when 'needs_rebase' then 'red exclamation'
    when 'open' then 'hourglass half'
    when 'accepted' then 'green check'
    when 'abandoned' then 'remove'
    end
  end

  def target_branch_options
    options = MergeRequest.distinct.where(project_id: @project.id).order('target_branch ASC').pluck(:target_branch)
    options.unshift(['any branch', ''])
  end

  def member_options
    options = User.all.pluck(:name, :id)
    options.unshift(['anyone', ''])
  end
end
