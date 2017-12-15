module Islay::Admin::PagesHelper
  def contents_field(slug, type, val)
    name = "page[contents][#{slug}]"

    case type
    when :image
      vals = @assets.map do |a|
        opts = {:value => a.id, 'data-preview' => a.previews.url(:thumb_medium), 'data-name' => a.name, 'data-type' => a.type}
        opts[:selected] = 'selected' if val and val.asset_id == a.id
        content_tag('option', a.name, opts)
      end

      select_tag(name, vals.join.html_safe, :include_blank => 'No image')
    when :text, :markdown
      text_area_tag(name, val)
    when :color
      text_field_tag(name, val, type: 'color')
    when :string
      text_field_tag(name, val)
    end
  end
end
