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

class UserMailer < ApplicationMailer
  default from: Rails.configuration.email_sender

  def verify_email(user, url)
    @user = user
    @url = url
    mail(to: @user.email, subject: t('landing.welcome'))
  end

  def password_reset(user, url)
    @user = user
    @url = url
    mail to: user.email, subject: t('reset_password.subtitle')
  end

  def send_invitation params
    @template = EmailTemplate.find_by_name('Meeting Scheduled')
    params["group-a"].each do |index, user|
      if User.find_by(email: user["text-input"]).present?
        @user = user["text-input"] 
        (mail to: @user, subject: t('user_invitation.subtitle'), body: @template.template_details).deliver
      end
    end
  end

  def send_token_to_user user
    @template = EmailTemplate.find_by_name('Token Information')
    @user = user
    mail to: user.email, subject: t('user_token_information.subtitle')
  end

end
