require 'haml'
require 'sass-rails'
require 'compass-rails' # This is temporary. By rights this needs to go into the assets group
require 'devise'
require 'simple_form'
require 'schema_plus'
require 'carrierwave'
require 'carrierwave_backgrounder'
require 'mime/types'
require 'streamio-ffmpeg'
require 'resque'
require 'resque/server'
require 'zipruby'

require "islay/engine"
require "islay/form_builder"
require "islay/active_record"
require "islay/carrierwave"
require "islay/extensions"

# Use require dependency to get around mixins going missing
# after class reloading.
require_dependency "islay/controller"
require_dependency "islay/helpers"

module Islay
end
