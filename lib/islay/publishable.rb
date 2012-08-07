module Islay
  module Publishable
    def self.included(klass)
      klass.before_save :update_publication_details
    end

    private

    def update_publication_details
      if published_changed?
        if published?
          self.published_at = Time.now
          self.first_published_at = Time.now unless first_published_at?
        else
          self.published_at = nil
        end
      end
    end
  end
end
