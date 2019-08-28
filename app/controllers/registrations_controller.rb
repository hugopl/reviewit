class RegistrationsController < Devise::RegistrationsController
  def regenerate_token
    current_user.generate_api_token
    current_user.save
    flash[:notice] = 'Token regenerated, current CLI setups will not work until updated.'
    redirect_to action: :edit
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :time_zone, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :time_zone,
                                 :password, :password_confirmation, :current_password,
                                 :notify_mr_creation_by_email,
                                 :notify_mr_update_by_email,
                                 :notify_mr_creation_by_webpush,
                                 :notify_mr_update_by_webpush,
                                 :notify_mr_ci_by_webpush,
                                 :notify_mr_status_by_webpush)
  end
end
