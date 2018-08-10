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

        env.register_preprocessor "text/css", extension_style_preprocessor
      end


      admin_scripts = entries.select {|n, e| e.admin_scripts?}.keys.map {|k| "//= require #{k}/admin/#{k}"}.join("\n")

      app.config.assets.unregister_preprocessor "application/javascript", ::Sprockets::DirectiveProcessor

      app.config.assets.register_preprocessor "application/javascript", :extension_scripts do |context, data|
        if context.logical_path.match(%r{admin/islay})
          data.gsub(%r{//= require_extensions}, admin_scripts)
        else
          data
        end
      end

      app.config.assets.register_preprocessor "application/javascript", ::Sprockets::DirectiveProcessor

      # Add Islay JS and CSS to the precompile
      app.config.assets.precompile += ['islay/admin/islay.js', 'islay/admin/islay.css', 'islay/admin/islay_print.css']
    end
  end
end
