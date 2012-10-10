class Page < ActiveRecord::Base
  has_many :page_assets do
    # Extracts an asset from the association by it's name.
    #
    # @param String name
    #
    # @return [Asset, nil]
    def by_name(name)
      if self[0]
        select {|a| a.name == name.to_s}.first
      else
        where(:name => name).first
      end
    end
  end

  has_many :features,           :order => 'position ASC'
  has_many :published_features, :order => 'position ASC', :conditions => "published = true", :class_name => "Feature"

  has_many :assets,     :through => :page_assets
  has_many :images,     :through => :page_assets, :source => :asset, :class_name => 'ImageAsset'
  has_many :documents,  :through => :page_assets, :source => :asset, :class_name => 'DocumentAsset'
  has_many :audio,      :through => :page_assets, :source => :asset, :class_name => 'AudioAsset'
  has_many :video,      :through => :page_assets, :source => :asset, :class_name => 'VideoAsset'

  track_user_edits

  attr_accessible :contents, :slug, :features_attributes

  accepts_nested_attributes_for :features,
                                :reject_if     => proc {|f| f.values.map(&:blank?).all?},
                                :allow_destroy => true

  before_save :update_page_assets

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

  # Checks to see if this page has been configured to have features attached to
  # it.
  #
  # @return Boolean
  def features?
    definition.features?
  end

  # The configuration and value merged together.
  #
  # @param [Symbol, String] name
  #
  # @return Hash
  def content_with_config(name)
    definition.contents[name.to_sym].merge(:value => contents[name])
  end

  # The contents defined against the page. For any contents that are missing,
  # we stub it out.
  #
  # @return Hash
  def contents
    @contents ||= definition.contents.inject({}) do |acc, c|
      name, config = c

      acc[name] = case config[:type]
      when :image
        page_assets.by_name(name)
      else
        entries[name.to_s] || ''
      end

      acc
    end
  end

  # Updates the content entries for the page.
  #
  # @param Hash updates
  #
  # @return Hash
  def contents=(updates)
    @contents = updates.inject({}) do |acc, u|
      name, val = u

      case content_type(name)
      when :image
        if val.blank?
          asset = page_assets.by_name(name)
          page_assets.destroy(asset) if asset

          acc[name] = nil
        else
          asset = page_assets.by_name(name) || page_assets.build(:name => name)
          asset.asset_id = val

          acc[name] = asset
        end
      else
        acc[name] = self.entries[name] = val
      end

      acc
    end
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

  def update_page_assets
    page_assets.each do |pa|
      pa.save if pa.changed?
    end
  end
end
