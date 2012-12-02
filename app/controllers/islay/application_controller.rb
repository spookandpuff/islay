class Islay::ApplicationController < ActionController::Base

  private

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

