# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  def self.parse_template(template, attrs = {})
    result = template.template_details
    attrs.each do |field, value|
      result.gsub!("{{#{field}}}", value)
    end
    result.gsub!(/\{\{\.w+\}\}/, '')
    result
  end
end
