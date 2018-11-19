# This became true when migrating Rails 4 apps to 5. We don't want it in Islay.
# This line is currently required in the host application's application.rb
# - need to find a way to include it in the engine and not have it overridden.
Rails.application.config.active_record.belongs_to_required_by_default = false
