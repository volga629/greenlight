require Rails.root.join('lib', 'rails_admin', 'invites_email.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::InvitesEmail)

RailsAdmin.config do |config|

config.authenticate_with do
 warden.authenticate! scope: :admin
end

config.current_user_method(&:current_admin)


config.included_models = [
    "EmailTemplate",
    "User",
    "Admin",
    "Room",
  ]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    invites_email
  end
end