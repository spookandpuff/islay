class FFMPEGUploader < AssetUploader
  def manipulate!(generate = true, &blk)
    cache_stored_file! if !cached?

    if generate
      directory = File.dirname(current_path)
      tmpfile   = File.join(directory, "tmpfile")

      FileUtils.mv(current_path, tmpfile)

      movie = FFMPEG::Movie.new(tmpfile)
      result = yield(movie, path)

      File.delete(tmpfile)
    else
      yield(FFMPEG::Movie.new(current_path), current_path)
    end
  end

  def transcode(opts)
    manipulate! do |movie, path|
      movie.transcode(path, opts)
    end
  end
end
