class Islay::Public::ApplicationController < ActionController::Base
  layout 'islay/public'

  helper_method :path

  private

  # Will either redirect the user back to the originating URL or another URL
  # specified via the params. A redirection is specified using the
  # _return_to param key.
  def bounce_back
    redirect_to params[:_return_to] ? params[:_return_to] : request.referrer
  end

  # A shortcut for generating routes namespaced to the Admin module.
  def path(*args)
    opts = args.pop if args.last.is_a?(Hash)
    first, second, rest = args

    url_opts = if first.is_a?(::ActiveRecord::Base)
      [[:public, *args], opts]
    elsif first.is_a?(Symbol)
      if second.is_a?(::ActiveRecord::Base) || second.is_a?(Symbol)
        [[first, :public, second, *rest], opts]
      else
        [[:public, *args], opts]
      end
    end

    url_opts.compact!

    polymorphic_url(*url_opts)
  end
end
