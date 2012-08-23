module Islay::Public::ApplicationHelper
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

  # Look up and render content from the pages table.
  #
  # @param Symbol name
  # @param Symbol content
  # @param Hash opts
  #
  # @return [String, nil]
  def content(name, content, opts = {})
    page = Islay::Pages.definitions[name]
    raise "The page '#{name}' has not been defined" if page.nil?
    raise "The content '#{content}' has not been defined" if page.contents[content].nil?

    if record = page.record
      config = record.content_with_config(content)

      case config[:type]
      when :markdown  then render_markdown(config[:value], opts[:level] || 1)
      when :text      then simple_format(config[:value])
      when :string    then config[:value]
      end
    end
  end
end
