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
    params.require(:user).permit(:name, :email, :time_zone, :password, :password_confirmation, :current_password)
  end
end
