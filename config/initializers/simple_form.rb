SimpleForm.setup do |config|
  config.wrappers :default, :class => :field, :hint_class => :hinted, :error_class => :errored do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label
    b.wrapper :tag => 'div', :class => 'input-wrapper' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => :div, :class => :error }
    end
    b.use :hint,  :wrap_with => { :tag => :span, :class => :hint }
  end

  config.wrappers :check_boxes, :class => :field, :hint_class => :hinted, :error_class => :errored do |b|
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label
    b.wrapper :tag => 'div', :class => 'checkbox-el-options' do |ba|
      ba.use :input
    end
    b.use :hint,  :wrap_with => { :tag => :span, :class => :hint }
    b.use :error, :wrap_with => { :tag => :span, :class => :error }
  end

  config.default_wrapper = :default
  config.boolean_style = :nested
  config.button_class = 'button'
  config.error_notification_tag = :div
  config.error_notification_class = 'alert alert-error'

  config.collection_wrapper_class = 'group'
  config.label_text = lambda { |label, required, explicit_label| "#{label}" }
  config.label_class = nil

  config.browser_validations = false

  config.cache_discovery = !Rails.env.development?
end
