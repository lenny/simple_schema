require 'typed_model/types'

module TypedModel
  module Validators
    module_function

    def recognized?(sym)
      respond_to?("assert_#{sym}")
    end

    def validate(sym, value)
      method_name = "assert_#{sym}"
      unless respond_to?(method_name)
        raise "Unrecognized validation '#{sym}'"
      end
      send(method_name, value)
    end

    def assert_timestamp(v)
      if Types.timestamp(v).nil?
        :invalid
      end
    end

    def assert_required(v)
      if v.nil? || (v.respond_to?(:empty?) && v.empty?)
        :required
      end
    end

    alias assert_not_blank assert_required

    def assert_not_nil(v)
      if v.nil?
        :required_not_nil
      end
    end

    def assert_string(v)
      if Types.string(v).nil?
        :invalid
      end
    end

    def assert_integer(v)
      if Types.integer(v).nil?
        :invalid
      end
    end
  end
end

