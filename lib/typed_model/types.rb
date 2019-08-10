module TypedModel

  # Supported Types/Type coercion
  #
  # Type checking methods (e.g. `boolean`, `integer`, etc..) should return
  # value of type if "reasonably" coercible, otherwise nil.
  #
  # "Reasonable" = reasonable valid over the wire data for type. E.g. String 'true'
  # is reasonable for a declared :boolean. Likewise, boolean is reasonable
  # for declared string, but Hash not so much.
  #
  #
  class Types
    PRIMITIVE_CLASSES = Set.new([String, TrueClass, FalseClass, Integer, Float, Fixnum])

    class << self
      def recognized?(t)
        respond_to?(t)
      end

      def typecast(sym, value)
        send(sym, value) || value
      end

      def timestamp(v)
        if v.respond_to?(:monday?)
          v
        else
          Time.parse(v)
        end
      rescue
        nil
      end

      def boolean(v)
        case v
        when "true", true then
          true
        when "false", false then
          false
        else
          nil
        end
      end

      def integer(v)
        Integer(v)
      rescue
        nil
      end

      def map(v)
        maplike?(v) ? v : nil
      end

      def seq(v)
        return nil if v.nil?
        return v if v.is_a?(Array)
        return v.to_a if v.respond_to?(:to_a) && !maplike?(v)
        nil
      end

      def string(v)
        primitive?(v) ? v.to_s : nil
      end

      private

      def maplike?(v)
        v.respond_to?(:each_pair)
      end

      def primitive?(v)
        PRIMITIVE_CLASSES.include?(v.class)
      end
    end
  end
end
