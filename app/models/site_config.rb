class SiteConfig < ActiveRecord::Base
  include Islay::Coercion
  
  validations_from_schema

  after_initialize :create_attributes

  def merged_config_data
    config_values = configuration.reduce({}) do |a, (k, v)|
      a[k] = {value: v}
      a
    end

    configuration_info.reduce({}) do |a, (k, v)|
      a[k] = v.merge(config_values[k]) if config_values[k]
      a
    end.deep_symbolize_keys

  end

  # Merges the configuration template and any set values in a format suitable for display
  #
  # @return Hash
  def display_config
    merged_config_data.each do |k, v|
      v[:value] ||= v[:default] || ''
    end
  end

  private

  # Define the keys in the configuration info as attribute methods
  def create_attributes
    merged_config_data.each do |k, v|
      send("define_#{v[:type].downcase}", k, v) if v[:type]
    end
  end
  
  def define_enum(name, opts = {})
    define_attribute(name, :enum, :string, opts)
  end

  def define_string(name, opts = {})
    define_attribute(name, :string, :string, opts)
  end

  def define_text(name, opts = {})
    define_attribute(name, :text, :string, opts)
  end

  def define_boolean(name, opts = {})
    define_attribute(name, :boolean, :boolean, opts)
  end

  def define_date(name, opts = {})
    # Using composed of here is a dirty hack to get around a bug in
    # ActiveRecord i.e. MultiAttributeAssignmentError. A long lived and
    # still to be fixed issue. Derp.
    self.class_eval do
      composed_of(
        name,
        :class_name   => 'Date',
        :mapping      => %w(Date to_s),
        :constructor  => Proc.new {|item| item },
        :converter    => Proc.new {|item| item }
      )
    end

    define_attribute(name, :date, :date, opts)
  end

  def define_integer(name, opts = {})
    define_attribute(name, :integer, :integer, opts)
  end

  def define_float(name, opts = {})
    define_attribute(name, :float, :float, opts)
  end

  # Defines an attribute which stores an instance of SpookAndPuff::Money
  #
  # @param Symbol name
  # @param Hash opts
  # @return nil
  def define_money(name, opts = {})
    define_attribute(name, :money, :money, opts)
  end

  class ExistingAttributeError < StandardError
    def initialize(col)
      @message = "Attribute :#{col} is already defined"
    end

    def to_s
      @message
    end
  end

  def define_validations(name, type, primitive, opts)
    if opts[:required]
      @model.validates_presence_of(name)
    end

    if opts[:format]
      @model.validates_format_of(name, opts[:format])
    end

    if opts[:length]
      @model.validates_length_of(name, opts[:length])
    end

    if primitive == :integer || primitive == :float
      config = {}

      if primitive == :integer
        config[:only_integer] = true
      end

      if opts[:greater_than]
        config[:greater_than] = opts[:greater_than]
      end

      if opts[:less_than]
        config[:less_than] = opts[:less_than]
      end

      unless opts[:required]
        config[:allow_nil] = true
      end

      @model.validates_numericality_of(name, config)
    end

    if opts[:values] and type != :foreign_key
      values = opts[:values].is_a?(Hash) ? opts[:values].values : opts[:values]
      @model.validates_inclusion_of(name, :in => values, :allow_nil => true)
    end
  end

  def define_attribute(name, type, primitive, opts)
    raise ExistingAttributeError.new(name) if column_names.include?(name)

    reader = case primitive
    when :array
      %{
        if format == :string
          coerce_#{primitive}(configuration['#{name}']).join(', ')
        else
          coerce_#{primitive}(configuration['#{name}'])
        end
      }
    else
      %{coerce_#{primitive}(configuration['#{name}']) }
    end

    writer = case primitive
    when :array
      %{
        self[:configuration] = self[:configuration].merge('#{name}' => v)
      }
    else
      %{self[:configuration] = self[:configuration].merge('#{name}' => coerce_#{primitive}(v))}
    end

    self.class_eval %{
      def #{name}(format = :native)
        #{reader}
      end

      def #{name}=(v)
        #{writer}
      end
    }

    define_validations(name, type, primitive, opts)

    nil
  end

  def column_names
    @column_names ||= self.class.columns.map {|c| c.name.to_sym}
  end
  
end