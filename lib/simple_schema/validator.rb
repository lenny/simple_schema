require 'simple_schema/validators'

module SimpleSchema
  class Validator
    class << self
      def build(arg)
        if arg.respond_to?(:validate) && arg.respond_to?(:name)
          return arg
        end
        if arg.is_a?(Symbol)
          if Validators.recognized?(arg)
            new_builtin_validator(arg)
          else
            raise "Unrecognized validation '#{arg}'"
          end
        else
          raise "failed to create validator from '#{arg}'"
        end
      end

      def from_primitive(t)
        new(t) do |v|
          errors = []
          if v != nil && (msg = send("assert_#{t}", v))
            errors << msg
          end
          errors
        end
      end

      private

      def new_builtin_validator(sym)
        new(sym) do |v|
          errors = []
          if (msg = Validators.validate(sym, v))
            errors << msg
          end
          errors
        end
      end
    end

    attr_reader :name, :f

    def initialize(name, &blk)
      @name = name
      @f = blk
    end

    def validate(value)
      f.call(value)
    end
  end
end

