class MergeRequestMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def created(mr)
    @author = mr.author
    @mr = mr

    headers('Message-ID' => message_id(mr))
    send_email(mr.project.users)
  end

  def updated(user, mr, params)
    @author = user
    @mr = mr
    @action = action(params)
    @comments = params[:comments]

    headers('In-Reply-To' => message_id(mr))
    send_email(mr.people_involved)
  end

  private

  def send_email(users)
    fail('No author or merge request defined!') if @author.nil? || @mr.nil?

    cc = email_adresses(users)
    return if cc.empty?

    to = cc.pop
    mail(subject: subject, to: to, cc: cc)
  end

  def email_adresses(users)
    (users.to_a - [@author]).map(&:email_address)
  end

  def subject
    "[#{@mr.project.name}, MR-#{@mr.id}] #{@mr.subject}"
  end

  def action(params)
    case params[:mr_action]
    when 'Accept' then 'accepted'
    when 'Abandon' then 'abandoned'
    else
      'commented on'
    end
  end

  def message_id(mr)
    id_right = Rails.application.config.action_mailer[:default_options][:from].gsub(/.+@/, '')
    id_left = Digest::MD5.hexdigest("#{mr.id}#{mr.created_at}")
    "<#{id_left}@#{id_right}>"
  end
end
