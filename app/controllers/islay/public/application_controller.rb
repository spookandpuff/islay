class Islay::Public::ApplicationController < Islay::ApplicationController
  layout 'islay/public'

  helper_method :path

  private

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
