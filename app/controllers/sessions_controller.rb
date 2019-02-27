# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:omniauth, :fail]
  after_action :login_user_detail, only: [:create]
  after_action :login_omniauth_user_detail, only: [:omniauth]
  # GET /users/logout
  def destroy
    logout
    redirect_to root_path
  end

  # POST /users/login
  def create
    user = User.find_by(email: session_params[:email])
    if user && !user.greenlight_account?
      redirect_to root_path, alert: I18n.t("invalid_login_method")
    elsif user.try(:authenticate, session_params[:password])
      if user.email_verified
        login(user)
      else
        redirect_to(account_activation_path(email: user.email)) && return
      end
    else
      redirect_to root_path, alert: I18n.t("invalid_credentials")
    end
  end

  # GET/POST /auth/:provider/callback
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    login(user)
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    omniauth_fail
  end

  # POST /auth/failure
  def omniauth_fail
    redirect_to root_path, alert: I18n.t(params[:message], default: I18n.t("omniauth_error"))
  end

  private

  def login_user_detail
    user = User.find_by_email(session_params[:email])
    user.update_attribute(:last_sign_in_at, Time.now) if user.present?
  end

  def login_omniauth_user_detail
    user = User.from_omniauth(request.env['omniauth.auth'])
    user.update_attribute(:last_sign_in_at, Time.now) if user.present?
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
