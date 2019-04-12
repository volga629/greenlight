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

  def send_invitation(params)
    params["group-a"].each do |_index, user|
      next unless User.find_by(email: user["text-input"]).present?
      @template = EmailTemplate.find_by_name('Meeting Scheduled')
      @user = User.find_by(email: user["text-input"])
      @room = Room.find_by(uid: params[:room_uid])
      details = { user_name: @user.name, room_name: @room.name, date: DateTime.now.strftime("%m/%d/%Y") }
      @new_template = EmailTemplate.parse_template(@template, details)
      @content = ActionView::Base.full_sanitizer.sanitize(@new_template)
      send_email_to_user(@user, @content)
    end
  end

  def send_email_to_user(user, _body)
    @user = user.email
    (mail to: @user, subject: t('user_invitation.subtitle')).deliver
  end

  def send_token_to_user(user)
    @template = EmailTemplate.find_by_name('Token Information')
    @user = user
    mail to: user.email, subject: t('user_token_information.subtitle')
  end
end
