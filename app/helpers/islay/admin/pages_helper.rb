module Islay::Admin::PagesHelper
  def contents_field(slug, type, val)
    name = "page[contents][#{slug}]"

    case type
    when :image
      vals = @assets.map do |a|
        opts = {:value => a.id, 'data-preview' => a.previews.url(:thumb_medium)}
        opts[:selected] = 'selected' if val and val.id = a.id
        content_tag('option', a.name, opts)
      end

      select_tag(name, vals.join.html_safe, :include_blank => true)
    when :text, :markdown
      text_area_tag(name, val)
    when :string
      text_field_tag(name, val)
    end
  end
end
