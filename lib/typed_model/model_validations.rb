require 'time'
require 'set'
require 'typed_model/errors'

module TypedModel

  # Supplies a simple Errors facility with common validations
  #
  # Implementations that mix in this module are expected to plug in validations
  # by overriding the `validate` method and/or adding `before_validation` hooks.
  #
  # Calling `valid?` will return true or false and leave errors accessible
  # via `errors` which returns a Map<String,Array> of messages keyed by attribute.
  #
  module ModelValidations
    attr_reader :errors

    def self.included(base)
      super
      base.class_eval do
        class << self
          def before_validation(fname)
            (@before_validation_callbacks ||= []) << fname
          end

          def before_validation_callbacks
            ancestors.reverse.each_with_object([]) do |c, callbacks|
              callbacks.concat(c.instance_variable_get(:@before_validation_callbacks) || [])
            end
          end
        end
      end
    end

    def add_error(key, msg)
      errors.add(key, msg)
    end

    def assert_not_blank(field)
      v = send(field)
      add_error(field, :required) unless v.to_s.match(/\S+/)
    end

    def assert_timestamp(field)
      v = send(field)
      if !v.is_a?(Time)
        s = v.to_s
        if s.match(/\S/)
          send("#{field}=", Time.parse(s))
        end
      end
    rescue
      add_error(field, :invalid)
    end

    def valid?
      self.class.before_validation_callbacks.each do |fname|
        send(fname)
      end
      validate
      errors.empty?
    end

    def errors
      @errors ||= Errors.new
    end

    def each_error(&blk)
      errors.each_error(&blk)
    end

    protected

    def validate

    end
  end
end

