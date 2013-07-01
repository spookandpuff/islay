module Islay
  module Coercion
    def coerce_string(v)
      v.to_s
    end

    def coerce_date(v)
      if v.blank?
        Date.today
      else
        case v
        when String then Date.parse(v)
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
  end
end
