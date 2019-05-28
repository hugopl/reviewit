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
    if mr.closed?
      "Closed #{distance_of_time_in_words(Time.now, mr.updated_at)} ago,"
    else
      last_patch = mr.patch
      return if last_patch.nil?

      time = last_patch.updated_at
      last_comment = last_patch.comments.order('id DESC').limit(1).first
      time = last_comment.created_at if last_comment
      time = distance_of_time_in_words(Time.now, time)
      "Pending for #{time}"
    end
  end

  def should_show_patch_comment_divisor(patch, main_patch)
    return patch.comments.general.any? if patch == main_patch

    patch.comments.general.any?
  end

  def interdiff_view?
    @from.nonzero?
  end

  def diff_file_status(file)
    flags = {}
    if file.new?
      flags['green'] = 'new'
      flags['chmod-changed'] = "chmod #{file.new_chmod}"
    elsif file.deleted?
      flags['red'] = 'deleted'
    elsif file.renamed?
      flags['blue'] = "renamed #{file.similarity}"
    elsif file.chmod_changed?
      flags['teal'] = "chmod change: #{file.old_chmod} → #{file.new_chmod}"
    end

    # interdiff tags
    flags['grey'] = file.interdiff_tag if file.interdiff_tag

    flags.map do |flag, label|
      content_tag(:div, label, class: "ui #{flag} label tiny js-deleted-file")
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
      extra = "On #{version.ordinalize} version"
    end

    output = link_to(content, project_merge_request_path(@project, @mr, options))
    output += content_tag(:span, extra, class: 'flag patch-warning') unless extra.blank?
    output
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
      "<i class=\"#{ci_icon(mr.patch)} icon\"></i> #{mr.target_branch}".html_safe
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
