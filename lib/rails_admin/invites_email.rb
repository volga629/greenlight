module RailsAdmin
  module Config
    module Actions
      class InvitesEmail < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:object].class == EmailTemplate
        end
        # We want the action on members, not the Users collection
        register_instance_option :member do
          true
        end
        register_instance_option :link_icon do
          'icon-question-sign'
        end
        # You may or may not want pjax for your action
        # register_instance_option :pjax? do
        #   false
        # end

         register_instance_option :controller do
          proc do
            @users =User.all
            @templates = EmailTemplate.all
          end
        end

      end
    end
  end
end