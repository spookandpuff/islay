class DocumentUploader < AssetUploader
  def preview
    ext   = File.extname(current_path)
    dir   = File.dirname(current_path)
    name  = File.basename(current_path).split('.').first

    output = case ext
    when '.pdf', '.psd'
      pdf = Magick::ImageList.new(current_path).first
      pdf.scale(300, 300)
      output = File.join(dir, "preview_#{name}.jpg")
      pdf.write(output)

      output
    end

    File.open(output) if output
  end
end
