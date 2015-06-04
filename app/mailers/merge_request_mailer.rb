class MergeRequestMailer < ApplicationMailer
  def updated(user, mr, params)
    @author = user
    @mr = mr
    @action = action(params)
    @comments = params[:comments]

    subject = "[#{mr.project.name}, MR-#{mr.id}] #{mr.subject}"
    cc = (mr.people_involved - [user]).map(&:email_address)
    to = cc.pop

    mail(subject: subject, to: to, cc: cc) unless to.nil?
  end

  private

  def action(params)
    case params[:mr_action]
    when 'Accept' then 'accepted'
    when 'Abandon' then 'abandoned'
    else
      'commented on'
    end
  end
end
