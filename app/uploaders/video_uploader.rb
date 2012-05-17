class VideoUploader < AssetUploader
  # https://github.com/streamio/streamio-ffmpeg
  # movie.screenshot("screenshot.bmp", :seek_time => 5, :resolution => '320x240')
  # widescreen_movie.transcode("movie.mp4", options, transcoder_options)

  def manipulate!(&blk)
    cache_stored_file! if !cached?

    directory = File.dirname(current_path)
    tmpfile   = File.join(directory, "tmpfile")

    FileUtils.mv(current_path, tmpfile)

    movie = FFMPEG::Movie.new(tmpfile)
    result = yield(movie, path)

    File.delete(tmpfile)
  end

  def transcode(opts)
    manipulate! do |movie, path|
      movie.transcode(path, opts)
    end
  end

  process :screenshot

  def screenshot
    movie = FFMPEG::Movie.new(current_path)
    directory = File.dirname(current_path)
    path = File.join(directory, "screenshot.jpg")
    at = (movie.duration / 2).round
    movie.transcode(path, :custom => "-ss #{at} -vframes 1 -f image2")
    model.preview = File.open(path)
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
