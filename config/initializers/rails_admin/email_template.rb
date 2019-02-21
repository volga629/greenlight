RailsAdmin.config do |config|
  config.model EmailTemplate do
    edit do
      field :name, :string
      field :template_details, :ck_editor
    end
  end
end
