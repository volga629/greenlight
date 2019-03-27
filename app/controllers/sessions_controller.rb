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
    debugger
    @user = User.find_by(email: session_params[:email])
    if @user.present?
      generate_and_send_token(@user)
      respond_to do |format|
        format.js {render "create", :locals => {:user => @user} }
        format.html
      end
    else
      redirect_to root_path, notice: I18n.t("invalid_user_email")
    end
  end

  def verify_token_and_login
    user = User.find_by(token: session_params[:token])
    if user.present?
      login(user)
    elsif user && !user.greenlight_account?
      redirect_to root_path, notice: I18n.t("invalid_login_method")
    else
      redirect_to root_path, notice: I18n.t("invalid_credentials")
    end
  end

  def resend_token
    @user = User.find_by_uid(params[:id])
    generate_and_send_token(@user)
    respond_to do |format|
      format.js{}
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
    params.require(:session).permit(:email, :password, :token)
  end
end
