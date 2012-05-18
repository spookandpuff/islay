class VideoUploader < FFMPEGUploader
  def preview
    manipulate!(false) do |movie, path|
      directory = File.dirname(path)
      path = File.join(directory, "preview_#{File.basename(path)}.jpg")
      at = (movie.duration / 2).round
      movie.transcode(path, :custom => "-ss #{at} -vframes 1 -f image2")
      File.open(path)
    end
  end

  # TODO: Provide presets for these resolutions
  # 360p
  # 480p
  # 720p
  # 1080p

  # TODO: Provide a way to conditionally generate versions. Only some video
  # sizes would be needed for particular sites.

  # TODO: When transcoding, preserve the original format rather than assuming
  # we're getting a H264 file.
  version :v360p, :if => :encode_320p? do
    process :transcode => [{:video_codec => "libx264", :resolution => '640x360'}]
  end

  def encode_320p?(movie)
    !!model.encode_options[:v320p]
  end
end
