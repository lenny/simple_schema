require 'typed_model/model_validations'
require 'typed_model/attribute_definition'

module TypedModel

  # Introduce a DataModelBase class for declaring structure
  # - data mapping (data -> object -> data)
  # - declared types
  # - declared validations
  # - Nested models
  #
  # e.g.
  # class Address
  #   include DataModelBase
  #   attribute :street, type: string, validations: [:required]
  # end
  #
  # class Employee
  #   include DataModelBase
  #   attribute :name, type: :string, validations: [:required]
  #   attribute :primary_address, type: Address, validations: [:required]
  #   attribute :alternate_addresses, seq_of: Address
  # end
  module DataModelBase
    def self.included(base)
      super
      base.class_eval do
        include ModelValidations

        before_validation :validate_declared_attributes

        class << self
          def attribute(name, opts = {})
            @declared_attributes ||= {}
            attribute_def = AttributeDefinition.new(opts.merge(name: name))
            @declared_attributes[name.to_sym] = attribute_def
            @declared_attributes[attribute_def.mapping_key.to_sym] = attribute_def
            attr_reader name
            define_method "#{name}=" do |v|
              instance_variable_set("@#{name}", attribute_def.typecast_value(v))
            end
          end

          def declared_attributes
            ancestors.reverse.each_with_object({}) do |c, attributes|
              attributes.merge!(c.instance_variable_get(:@declared_attributes) || {})
            end
          end
        end
      end
    end

    def initialize(values = {})
      self.attributes = values
    end

    def attributes=(values = {})
      return if values.nil?

      values.each_pair do |k, v|
        if (attr_def = self.class.declared_attributes[k.to_sym])
          setter = "#{attr_def.name}="
          send(setter, v) if respond_to?(setter)
        end
      end
    end

    def validate_declared_attributes
      self.class.declared_attributes.each do |(_, attr)|
        attr.validate(self)
      end
    end

    def to_data
      self.class.declared_attributes.each_with_object({}) do |(_, attr), h|
        data = attr.to_data(self)
        h[attr.mapping_key] = data unless data.nil?
      end
    end
  end
end

