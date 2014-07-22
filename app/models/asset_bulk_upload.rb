class AssetBulkUpload
  include ActiveModel::Validations

  attr_accessor :upload, :asset_group_id

  validates_presence_of :upload,          :message => 'You must choose a file to upload'
  validates_presence_of :asset_group_id,  :message => 'Choose collection to upload into'
  validate :is_zip_file

  def initialize(attrs = {})
    attrs.each {|k, v| send(:"#{k}=", v)}
  end

  def to_key
    [0]
  end

  def new_record?
    true
  end

  def enqueue
    Worker.enqueue!(upload.path, asset_group_id, Thread.current[:current_user])
  end

  private

  def is_zip_file
    if @upload and !@upload.original_filename.match(/\.zip$/)
      errors.add(:upload, 'You can only bulk upload Zip files')
    end
  end

  class Worker
    attr_accessor :file_path, :asset_group_id, :parent_group, :creator, :dir

    # Adds a new instance of the worker to the GirlFriday asset queue.
    #
    # @param String path
    # @param [String, Integer]
    # @param User
    #
    # @return Worker
    def self.enqueue!(path, group_id, creator)
      ASSET_QUEUE << self.new(path, group_id, creator)
    end

    # Create a new instance of the worker.
    #
    # @param String file_path
    # @param [String, Integer] asset_group_id
    # @param User creator
    def initialize(file_path, asset_group_id, creator)
      @file_path      = file_path
      @asset_group_id = asset_group_id
      @creator        = creator
    end

    # Unpacks the zip file, creates the corresponding groups for each directory
    # and enqueues each asset for processing.
    #
    # @return nil
    def perform
      begin
        Thread.current[:current_user] = creator
        self.parent_group = AssetGroup.find(asset_group_id)
        group_paths, asset_paths = unpack
        ActiveRecord::Base.transaction do
          groups = initialize_groups(group_paths)
          create_assets(groups, asset_paths)
        end
      ensure
        Thread.current[:current_user] = nil
        cleanup

        nil
      end
    end

    private

    # Splits a path into it's dirname and basename components. It does this as
    # you'd expect, unlike the methods on File, which suck.
    #
    # @param String path
    #
    # @return Arrray<String>
    def path_and_name(path)
      match = path.match(/(.+)\/(.+$)/)
      [match[1], match[2].split('.').max_by(&:length).underscore.humanize.titlecase]
    end

    # Unpacks the downloaded zip file and returns an array containing two entries;
    # paths for categories and paths for assets. Ignores osx system files.
    #
    # @returns Array<Array>
    def unpack
      self.dir = Rails.root + 'tmp' + SecureRandom.hex(20)
      FileUtils.mkdir(dir)

      dirs = []
      files = []

      Zip::Archive.open(file_path) do |archive|
        archive.each do |file|
          next if file.name =~ /__MACOSX/ or file.name =~ /\.DS_Store/
          destination = dir + file.name
          name = Pathname.new(file.name).cleanpath.to_s

          if file.directory?
            FileUtils.mkdir_p(destination)
            dirs << name
          else
            dirname = File.dirname(file.name)
            FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
            open(destination, 'wb') {|f| f << file.read}
            files << name
          end
        end
      end

      [dirs, files]
    end

    # @param Array<Pathname> paths
    #
    # @return Hash<AssetCategory>
    def initialize_groups(paths)
      paths.sort {|x,y| x.length <=> y.length}.reduce({}) do |acc, path|
        acc[path] = if path.include?('/')
          parent, name = path_and_name(path)
          create_or_find_group(name, acc[parent])
        else
          create_or_find_group(path.humanize, parent_group)
        end

        acc
      end
    end

    # Loads or creates the group specified by name and parent
    #
    # @param String name
    # @param AssetGroup parent
    #
    # @return AssetGroup
    def create_or_find_group(name, parent)
      conds = ["name = ? AND path = ?::ltree || ?", name, parent.path, parent.id.to_s]
      AssetGroup.where(conds).first || AssetGroup.create(:name => name, :parent => parent)
    end

    # Takes an array of path strings and generates an asset for each, generating
    # categories as necessary.
    #
    # @param Hash<AssetGroup> groups
    # @param Array<String> paths
    #
    # @return Array<Asset>
    def create_assets(groups, paths)
      paths.map do |path|
        file  = File.open(dir + path)
        asset = Asset.choose_type(path.split('.').last)
        if path.include?('/')
          path, name = path_and_name(path)
          group = groups[path]
        else
          group = parent_group
        end
        asset.updater = Thread.current[:current_user]
        asset.creator = Thread.current[:current_user]
        asset.update_attributes(:file => file, :name => name, :asset_group_id => group.id)
        asset
      end
    end

    # Cleans up any tmp files and directories.
    #
    # @return nil
    def cleanup
      if dir and File.exists?(dir)
        FileUtils.rm_rf(dir)
      end

      nil
    end
  end
end
