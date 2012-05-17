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

  def audio_bitrate(bitrate)
    manipulate! do |movie, path|
      movie.transcode(path, :audio_bitrate => bitrate)
    end
  end

  version :test do
    process :audio_bitrate => "128k"
  end
end
