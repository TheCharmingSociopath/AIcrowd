ActiveAdmin.register ParticipationTerms do
  controller do
    actions :all, except: [:edit, :destroy]
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column :id
    column :version
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.label 'Terms', class: 'ckeditor_label participation_terms'
      f.text_area :terms, class: 'ckeditor'
    end
    f.actions
  end

  show do |participation_terms|
    attributes_table do
      row :id
      row :version
      row :terms do
        sanitize_html(participation_terms.terms)
      end
      row :created_at
      row :updated_at
    end
  end
end
