# This class provides a select box for choosing an asset. It's implementation is
# very simple. In fact, the only notable thing it does is adding attributes
# — see the #input method.
class SingleAssetInput < SimpleForm::Inputs::CollectionSelectInput
  # Generates a select tag where the options have a data-preview attribute. This
  # attribute contains a URL to an image preview for the asset.
  #
  # @return String
  def input
    selected = object[attribute_name]
    vals = collection.map do |a|
      opts = {:value => a.id, 'data-preview' => a.previews.url(:thumb_medium)}
      opts[:selected] = 'selected' if a.id == selected
      template.content_tag('option', a.name, opts)
    end

    @builder.select(
      attribute_name,
      vals.join('').html_safe,
      input_options,
      input_html_options
    )
  end
end
