module Islay::Public::ApplicationHelper
  include ::Islay::ApplicationHelper

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
