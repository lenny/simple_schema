require 'spec_helper'

require 'simple_schema/validator'

module SimpleSchema
  RSpec.describe Validator do
    describe 'initializer' do
      it 'return value of specified block is returned from #validation' do
        validator = Validator.new('myvalidation') do |v|
          "foo #{v}"
        end
        expect(validator.validate('bar')).to eq('foo bar')
      end
    end

    describe '.build' do
      it 'returns validator for recognized types' do
        expect(Validator.build(:timestamp).validate('foo')).to_not be_nil
      end

      it 'it accepts Validator instance' do
        validator = Validator.new(:foo) do |v|
          "foo #{v}"
        end
        expect(Validator.build(validator).validate('bar')).to eq('foo bar')
      end

      it 'raises error given unrecognized symbol' do
        expect { Validator.build(:foo) }.to raise_error(/unrecognized validation/i)
      end

      it 'raises error when no Validator could be built' do
        expect { Validator.build(Object) }.to raise_error(/failed to create validator/i)
      end
    end
  end
end
