module Islay
  module Coercion
    def coerce_string(v)
      v.to_s
    end

    # Coerces the input into a SpookAndPuff::Money instance
    #
    # @param [String, BigDecimal, Numeric] v
    # @return SpookAndPuff::Money
    def coerce_money(v)
      SpookAndPuff::Money.new(v.to_s)
    end

    def coerce_date(v)
      if v.blank?
        Date.today
      else
        case v
        when String
            # A string may be a date string, or a rails select hash-as-a-string
            if v.include? '=>'
              Date.new(JSON.parse(v.gsub('=>',"':'")).values)
            else
              Date.parse(v)
            end
        else v
        end
      end
    end

    def coerce_boolean(v)
      case v
      when 0, "0", "f", "false", false  then false
      when 1, "1", "t", "true", true    then true
      end
    end

    def coerce_integer(v)
      v.to_i
    end

    def coerce_float(v)
      v.to_f
    end

    def coerce_array(v, separator = ',')
      v.split(separator) unless v.nil?
    end

    def coerce_bitmask(values, list)
      values = [*values].map { |v| v.to_sym }
      mask = (values & list).map { |v| 2**list.index(v) }.inject(0, :+)
      mask
    end

    def read_bitmask(values, list)
      list.reject do |v|
        ((values.to_i || 0) & 2**list.index(v)).zero?
      end
    end
  end
end
