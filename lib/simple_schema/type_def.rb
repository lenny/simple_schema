require 'simple_schema/seq_of'
require 'simple_schema/map_of'
require 'simple_schema/types'
require 'simple_schema/validator'

module SimpleSchema
  class TypeDef
    class << self
      def build(args)
        spec_map = args.respond_to?(:has_key?) ? args : { type: args }

        t, seq_of, map_of, validations = spec_map.values_at(:type, :seq_of, :map_of, :validations)

        validators = (validations || []).map do |v|
          Validator.build(v)
        end

        spec_opts = { type: t, validators: validators }

        if seq_of
          seq_spec = build(seq_of)
          new(spec_opts.merge(type: SeqOf.new(seq_spec)))
        elsif map_of
          key_spec_opts, val_spec_opts = map_of
          if val_spec_opts.is_a?(Array)
            val_spec_opts = { type: :map, map_of: val_spec_opts }
          end
          map_of = MapOf.new(build(key_spec_opts), build(val_spec_opts))
          new(spec_opts.merge(type: map_of))
        else
          new(spec_opts)
        end
      end
    end

    attr_accessor :value_type, :validators

    def initialize(values)
      @value_type = values[:type]
      @validators = (values[:validators] || [])
    end

    def typecast_value(v)
      if value_type
        if value_type.respond_to?(:typecast_value)
          value_type.typecast_value(v)
        elsif value_type.is_a?(Symbol) && Types.recognized?(value_type)
          Types.typecast(value_type, v)
        elsif value_type.is_a?(Class)
          instantiate_type(v)
        else
          raise "unrecognized type '#{value_type.inspect}'"
        end
      else
        v
      end
    end

    def validate(value, errors, key_prefix)
      validate_recognized_types(errors, key_prefix, value)

      execute_validators(errors, key_prefix, value)

      if value_type.respond_to?(:validate)
        value_type.validate(value, errors, key_prefix)
      end

      if value.respond_to?(:valid?) && value.respond_to?(:errors) && !value.valid?
        errors.merge!(value.errors, key_prefix)
      end
    end

    def to_data(value)
      if value_type.respond_to?(:to_data)
        value_type.to_data(value)
      elsif value.respond_to?(:to_data)
        value.to_data
      else
        value
      end
    end

    private

    def execute_validators(errors, key_prefix, value)
      validators.each_with_object(errors) do |v, errors|
        (v.validate(value) || []).each do |s|
          errors.add(key_prefix, s)
        end
      end
    end

    def validate_recognized_types(errors, key_prefix, value)
      if value_type.is_a?(Symbol) && Types.recognized?(value_type)
        if value != nil && Types.send(value_type, value).nil?
          errors.add(key_prefix, :invalid)
        end
      end
    end

    def instantiate_type(v)
      if v.is_a?(value_type)
        v
      else
        m = value_type.respond_to?(:build) ? :build : :new
        value_type.send(m, v)
      end
    end
  end
end


