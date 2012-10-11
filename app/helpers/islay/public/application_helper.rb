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
      when :image     then version_image_tag(config[:value].asset, opts[:version]) if config[:value]
      end
    end
  end

  # Look up an asset from a page content reference
  #
  # @param Symbol name
  # @param Symbol content
  #
  # @return [Asset, nil]
  def content_asset(name, content)
    page = Islay::Pages.definitions[name]
    raise "The page '#{name}' has not been defined" if page.nil?
    raise "The content '#{content}' has not been defined" if page.contents[content].nil?

    if record = page.record
      config = record.content_with_config(content)

      case config[:type]
      when :image     then config[:value].asset if config[:value]
      end
    end
  end

  # Returns the published features for the specified page.
  #
  # @param Symbol name
  #
  # @return Array<Feature, nil>
  def features(name)
    page = Islay::Pages.definitions[name]
    raise "The page '#{name}' has not been defined" if page.nil?

    if record = page.record
      record.published_features
    else
      []
    end
  end
end
