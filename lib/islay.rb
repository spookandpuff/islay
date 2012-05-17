require 'haml'
require 'sass-rails'
require 'compass-rails' # This is temporary. By rights this needs to go into the assets group
require 'devise'
require 'simple_form'
require 'schema_plus'
require 'carrierwave'
require 'mime/types'

require "islay/engine"
require "islay/controller"
require "islay/helpers"
require "islay/form_builder"
require "islay/active_record"

module Islay
end
