class VideoAsset < Asset
  self.kind = 'image'
  self.friendly_kind = 'Video'

  self.asset_processor = VideoAssetProcessor

  private

  def set_video_metadata
    upload.manipulate!(false) do |movie|
      # Video
      self.duration           = movie.duration
      self.video_bitrate      = movie.bitrate
      self.filesize           = movie.size
      self.video_codec        = movie.video_codec
      self.colorspace         = movie.colorspace
      self.width              = movie.width
      self.height             = movie.height
      self.video_frame_rate   = movie.frame_rate

      # Audio
      self.audio_codec        = movie.audio_codec
      self.audio_bitrate      = movie.audio_bitrate
      self.audio_sample_rate  = movie.audio_sample_rate
      self.audio_channels     = movie.audio_channels
    end
  end
end
