class AudioAsset < Asset
  self.kind = 'audio'
  mount_uploader :upload, AudioUploader

  before_save :set_audio_metadata

  private

  def set_audio_metadata
    upload.manipulate!(false) do |movie, path|
      self.audio_codec        = movie.audio_codec
      self.audio_bitrate      = movie.audio_bitrate
      self.audio_sample_rate  = movie.audio_sample_rate
      self.audio_channels     = movie.audio_channels
      self.duration           = movie.duration
    end
  end
end
