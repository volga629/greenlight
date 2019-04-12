# frozen_string_literal: true

module RailsAdmin
  module TemplatesHelper
    def dynamic_content_array
      "{{user_name}} {{room_name}} {{date-time}}"
    end
  end
end
