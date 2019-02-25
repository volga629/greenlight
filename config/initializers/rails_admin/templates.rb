RailsAdmin.config do |config|
  config.model EmailTemplate do
    edit do
      field :name, :string
      field :template_details, :ck_editor do
        css_class "col-md-10"
      end
      field :dynamic_content do
        help false
        css_class "col-md-2"
      	partial 'dynamic_content'
        label 'Dynamic Tags'
      end
    end
  end
end
