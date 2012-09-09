module Islay
  class Sprockets
    def self.configure(app)
      entries = Islay::Engine.extensions.entries

      # Append the style sheet paths from the different extensions
      styles = entries.map {|e| e[1].config[:engine].root + 'app/assets/stylesheets'}
      app.config.sass.load_paths.concat(styles)

      # Append the image dirs
      images = entries.map {|e| e[1].config[:engine].root + 'app/assets/images'}
      app.assets.paths.concat(images)

      # Append the javascript dirs
      scripts = entries.map {|e| e[1].config[:engine].root + 'app/assets/scripts'}
      app.assets.paths.concat(scripts)

      app.assets.paths << File.expand_path("../../../app/assets/fonts", __FILE__)

      # Generate import statements for extension admin styles
      admin_styles = entries.select {|n, e| e.admin_styles?}.keys.map {|k| "@import #{k}/admin/#{k}"}.join("\n")

      app.assets.register_preprocessor "text/css", :extension_styles do |context, data|
        if context.logical_path.match(%r{admin/islay})
          data << admin_styles
        else
          data
        end
      end

      admin_scripts = entries.select {|n, e| e.admin_scripts?}.keys.map {|k| "//= require #{k}/admin/#{k}"}.join("\n")

      app.assets.unregister_preprocessor "application/javascript", ::Sprockets::DirectiveProcessor

      app.assets.register_preprocessor "application/javascript", :extension_scripts do |context, data|
        if context.logical_path.match(%r{admin/islay})
          data.gsub(%r{//= require_extensions}, admin_scripts)
        else
          data
        end
      end

      app.assets.register_preprocessor "application/javascript", ::Sprockets::DirectiveProcessor

      # Add Islay JS and CSS to the precompile
      app.config.assets.precompile += ['islay/admin/islay.js', 'islay/admin/islay.css']
    end
  end
end
