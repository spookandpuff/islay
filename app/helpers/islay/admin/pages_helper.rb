module Islay::Admin::PagesHelper
  def contents_field(slug, type, val)
    name = "page[contents][#{slug}]"

    case type
    when :image
      select_tag(name, options_for_select(@assets, val ? val.id : nil), :include_blank => true)
    when :text, :markdown
      text_area_tag(name, val)
    when :string
      text_field_tag(name, val)
    end
  end
end
