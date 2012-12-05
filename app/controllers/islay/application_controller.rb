class Islay::ApplicationController < ActionController::Base

  private

  # A helper for generating paths without having to use the horrible *_path
  # helpers that Rails generates. It scopes paths to the specified module
  # — i.e. public or admin — and does some clever things to handle symbols,
  # AR records and combinations of those.
  #
  # @param Symbol mod the module/namespace in which the route is declared
  # @param Array<Symbol, ActiveRecord::Base, Hash> args
  #
  # @return String
  def render_path(mod, args)
    opts = args.pop if args.last.is_a?(Hash)
    first, second, rest = args

    url_opts = if first.is_a?(::ActiveRecord::Base)
      [[mod, *args], opts]
    elsif first.is_a?(Symbol)
      if second.is_a?(::ActiveRecord::Base) || second.is_a?(Symbol)
        [[first, mod, second, *rest], opts]
      else
        [[mod, *args], opts]
      end
    end

    url_opts.compact!

    polymorphic_url(*url_opts)
  end

  # A simple wrapper around Rail's ::force_ssl method, which conditionally
  # turns it on only if Settings.use_ssl? is true.
  #
  # @params Hash opts containing the key :only or :except, same as a before
  # filter
  #
  # @return nil
  def self.use_https(opts = {})
    force_ssl(opts) if Settings.use_https?
  end

  # Will either redirect the user back to the originating URL or another URL
  # specified via the params. A redirection is specified using the
  # _return_to param key.
  #
  # @return nil
  def bounce_back
    redirect_to params[:_return_to] ? params[:_return_to] : request.referrer
  end
end

