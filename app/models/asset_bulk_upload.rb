class AssetBulkUpload
  include ActiveModel::Validations

  attr_accessor :upload, :into, :new_album_name, :album

  validates_presence_of :upload,          :message => 'You must choose a file to upload'
  validates_presence_of :into,            :message => 'Choose or create an album to upload into'
  validates_presence_of :new_album_name,  :if => :create_new_album?
  validate :is_zip_file

  def initialize(attrs = {})
    attrs.each {|k, v| send(:"#{k}=", v)}
  end

  def to_key
    [0]
  end

  def create_new_album?
    @into == 'on'
  end

  def unpack!
    ActiveRecord::Base.transaction do
      @album = if create_new_album?
        AssetAlbum.create(:name => @new_album_name)
      else
        AssetAlbum.find(@into)
      end

      path = File.join(Rails.root, 'tmp', SecureRandom.hex(20))
      FileUtils.mkdir(path)

      begin
        Zip::Archive.open(@upload.path) do |ar|
          ar.each do |zf|
            if zf.directory?
              FileUtils.mkdir_p(zf.name)
            elsif !zf.name.match(/__MACOSX/)
              dirname = File.dirname(zf.name)
              FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
              file_path = File.join(path, zf.name)
              open(file_path, 'wb') do |f|
                f << zf.read
                asset = Asset.choose_type(File.extname(zf.name).split('.').last)
                asset.update_attributes!(:upload => f, :album => @album)
              end
            end
          end
        end
      ensure
        FileUtils.remove_dir(path) if File.exists?(path)
      end
    end
  end

  def candidates
    albums = AssetAlbum.all
    albums << AssetAlbum.new(:name => 'New Album')
  end

  private

  def is_zip_file
    if @upload and !@upload.path.match(/\.zip$/)
      errors.add(:upload, 'You can only bulk upload Zip files')
    end
  end
end
