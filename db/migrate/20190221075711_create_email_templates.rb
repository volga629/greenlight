# frozen_string_literal: true

class CreateEmailTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.text :template_details
      t.timestamps
    end
  end
end
