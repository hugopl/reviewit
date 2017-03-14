class UsersController < ApplicationController
  def configure_webpush
    subscription = params[:subscription]
    current_user.update_attributes(
      webpush_endpoint: subscription[:endpoint],
      webpush_auth: subscription[:keys][:auth],
      webpush_p256dh: subscription[:keys][:p256dh]
    )
    render json: 'ok'
  end
end
