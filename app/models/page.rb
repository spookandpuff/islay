class Page < ActiveRecord::Base
  track_user_edits

  attr_accessible :contents, :slug

  # Returns the name defined in the configuration for this page.
  #
  # @return String
  def name
    definition.name
  end

  def each
    contents.each do |slug, val|
      yield(slug, content_type(slug), content_name(slug), val)
    end
  end

  # The configuration and value merged together.
  #
  # @param [Symbol, String] name
  #
  # @return Hash
  def content_with_config(name)
    definition.contents[name.to_sym].merge(:value => entries[name.to_s])
  end

  # The contents defined against the page. For any contents that are missing,
  # we stub it out.
  #
  # @return Hash
  def contents
    @contents ||= definition.contents.keys.map(&:to_s).inject({}) do |acc, name|
      acc[name] = entries[name.to_s] || ''
      acc
    end
  end

  # Updates the content entries for the page.
  #
  # @param Hash updates
  #
  # @return Hash
  def contents=(updates)
    self.entries = @contents = updates
  end

  def content_name(name)
    definition.contents[name.to_sym][:name]
  end

  def content_type(name)
    definition.contents[name.to_sym][:type]
  end

  # Returns the content entries for the page, or stubs out an empty hash.
  #
  # @return Hash
  def entries
    self[:entries] ||= {}
  end

  private

  def definition
    @definition ||= Islay::Pages.definitions[slug.to_sym]
  end
end
