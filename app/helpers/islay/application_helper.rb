module Islay::ApplicationHelper
  # Takes a string containing markdown and generates HTML. It optionally accepts
  # a level param, which will rewrite the top header level e.g. it can convert
  # H1s to H2s, H2s to H3s etc.
  #
  # Escaping can also be specified, in which case and embeded HTML will be
  # escaped. This is on by default to prevent XSS attacks sneaking in
  #
  # @param String text the markdown
  # @param Integer level header level to rewrite to
  # @param Boolean escape controls escaping of embedded HTML
  #
  # @return String
  def render_markdown(text, level = 1, escape = true)
    content = if escape
      HTMLEntities.new.encode(text, :named)
    else
      text
    end

    if level > 1
      add = '#' * (level - 1)
      rewrite = content.gsub(/(?<sym>[#]+)(\s*)(?<title>\w+)/, "\\k<sym>#{add} \\k<title>")
      RDiscount.new(rewrite).to_html.html_safe
    else
      RDiscount.new(content).to_html.html_safe
    end
  end

  # Creates an image tag for the specified image asset and version. Optionally
  # if the :placeholder option is passed in, a div will be rendered in cases
  # where the asset is absent.
  #
  # @param Asset asset
  # @param Symbol version
  # @param Hash opts
  #
  # @return String
  def version_image_tag(asset, version, opts = {})
    if asset.nil?
      if opts[:placeholder]
        content_tag(:div, 'No Image', :class => 'image-missing')
      end
    else
      image_tag(asset.versions.url(version), opts)
    end
  end
end
