class ImageAsset < Asset
  self.kind = 'image'
  self.friendly_kind = 'Image'

  self.asset_processor = ImageAssetProcessor

  def dimensions
    "#{width}x#{height}" if width? and height?
  end

  # A predicate to checks if the image is landscape i.e. wider than it is high.
  #
  # @return [true, false]
  def landscape?
    orientation == :landscape
  end

  # A predicate to checks if the image is portrait i.e. taller than it is wide.
  #
  # @return [true, false]
  def portrait?
    orientation == :portrait
  end

  # A predicate to checks if the image is square i.e. width and height are the
  # same.
  #
  # @return [true, false]
  def square?
    orientation == :square
  end

  # Calculates the orientation of the image based on the width and height. If
  # for some reason the width/height attributes couldn't be stored, it will
  # return :unknown
  #
  # @return [:landscape, :portrait, :square, :unknown]
  def orientation
    @orientation ||= if width? and height?
      if width == height
        :square
      elsif width > height
        :landscape
      else
        :portrait
      end
    else
      :unknown
    end
  end
end
