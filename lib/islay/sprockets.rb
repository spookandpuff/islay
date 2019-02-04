module Islay
  class Sprockets

    def self.configure(app)
      entries = Islay::Engine.extensions.entries
      engine_roots = entries.select {|n, e| e.is_engine?}.map {|n, e| e.config[:engine].root}

      # Append the style sheet paths from the different extensions
      app.config.sass.load_paths.concat(engine_roots.map {|r| r + 'app/assets/stylesheets'})

      # Append the image dirs
      app.config.assets.paths.concat(engine_roots.map {|r| r + 'app/assets/images'})

      # Append the javascript dirs
      app.config.assets.paths.concat(engine_roots.map {|r| r + 'app/assets/javascripts'})

      # Add Islay's fonts dir
      app.config.assets.paths << File.expand_path("../../../app/assets/fonts", __FILE__)

      # Generate import statements for extension admin styles
      admin_styles = entries.select {|n, e| e.admin_styles?}.keys.map {|k| "@import #{k.to_s.downcase}/admin/#{k.to_s.downcase}"}.join("\n")

      app.config.assets.configure do |env|
        extension_style_preprocessor = -> (input) do
          if input[:filename].match(%r{admin/islay})
            input[:data] << admin_styles
          else
            input[:data]
          end
        end

        extension_script_preprocessor = -> (input) do
          @admin_scripts ||= Islay::Engine.extensions.entries.select {|n, e| e.admin_scripts?}.keys.map do |k|
            "//= require #{k.to_s.downcase}/admin/#{k.to_s.downcase}"
          end.join("\n")

          result = if input[:filename].match(%r{admin/islay})
            input[:data].gsub(%r{//= require_extensions}, @admin_scripts)
          else
            input[:data]
          end

          {data: result}
        end

        env.register_preprocessor "text/css", extension_style_preprocessor

        # For scripts, we are injecting more directives which need to be processed by ::Sprockets::DirectiveProcessor
        # Sprockets doesn't give control over the order, so we need to unregister the DirectiveProcessor, add our own,
        # then re-register DirectiveProcessor
        js_directive_processor = env.processors['application/javascript'].find{|p|p.is_a? ::Sprockets::DirectiveProcessor}

        env.unregister_preprocessor "application/javascript", js_directive_processor
        env.register_preprocessor "application/javascript", extension_script_preprocessor
        env.register_preprocessor "application/javascript", js_directive_processor

      end

      # Add Islay JS and CSS to the precompile
      app.config.assets.precompile += ['islay/admin/favicon.png', 'islay/admin/favicon.ico', 'islay/admin/islay.js', 'islay/admin/islay.css', 'islay/admin/islay_print.css']
    end
  end
end
