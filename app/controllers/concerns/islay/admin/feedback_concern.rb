module Islay
  module Admin
    module FeedbackConcern
      extend ActiveSupport::Concern

      included do
        # Render a message for the user.
        # This checks for the existence of content_for? and associated methods for safety
        # This allows the method to be used in controllers that don't inherit all of
        # ActionController's helper toolkit
        def feedback_message
          if respond_to?(:content_for?) and content_for?(:feedback_message)
            content_for :feedback_message
          else
            message = flash[:alert] || flash[:notice]
            render_to_string(
              :partial => 'islay/admin/shared/feedback_message',
              :locals => {:message =>  message}
            ).html_safe if message
          end
        end

        helper_method :feedback_message

      end
    end
  end
end
