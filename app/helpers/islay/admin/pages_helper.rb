module Islay::Admin::PagesHelper
  def contents_field(slug, type, val)
    case type
    when :text, :markdown
      text_area_tag("page[contents][#{slug}]", val)
    when :string
      text_field_tag("page[contents][#{slug}]", val)
    end
  end
end
