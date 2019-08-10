require 'spec_helper'
require 'typed_model/types'
require 'time'

module TypedModel
  RSpec.describe Types do
    describe '.timestamp' do
      it 'returns nil given nil' do
        expect(Types.timestamp(nil)).to be_nil
      end

      it 'returns same object given a Time' do
        t = Time.now
        expect(Types.timestamp(t)).to equal(t)
      end

      it 'returns nil if value cannot by coerced to a time' do
        expect(Types.timestamp('foo')).to be_nil
      end

      it 'coerces input to Time' do
        t = Time.now
        expect(Types.timestamp(t.iso8601).to_i).to eq(t.to_i)
      end
    end

    describe '.boolean' do
      it 'returns nil given nil' do
        expect(Types.boolean(nil)).to be_nil
      end

      it 'returns boolean true given boolean true' do
        expect(Types.boolean(true)).to eq(true)
      end

      it 'returns boolean true given string "true"' do
        expect(Types.boolean('true')).to eq(true)
      end

      it 'returns boolean false given boolean false' do
        expect(Types.boolean(false)).to eq(false)
      end

      it 'returns boolean false given string "false"' do
        expect(Types.boolean('false')).to eq(false)
      end

      it 'returns nil for non-boolean' do
        expect(Types.boolean('foo')).to be_nil
      end
    end

    describe '.integer' do
      it 'returns nil given nil' do
        expect(Types.integer(nil)).to be_nil
      end

      it 'returns integer given integer' do
        expect(Types.integer(5)).to eq(5)
      end

      it 'coerces integer strings' do
        expect(Types.integer('5')).to eq(5)
      end
    end

    describe '.map' do
      it 'returns nil given nil' do
        expect(Types.map(nil)).to be_nil
      end

      it 'returns same {} given {}' do
        m = {}
        expect(Types.map(m)).to eq(m)
      end

      it 'returns input given maplike input' do
        v = Class.new do
          def each_pair
            yield(:foo, 'foo')
          end
        end.new
        expect(Types.map(v)).to equal(v)
      end

      it 'returns nil given unrecognized input' do
        expect(Types.map('f')).to be_nil
      end
    end

    describe '.seq' do
      it 'returns nil given nil' do
        expect(Types.seq(nil)).to be_nil
      end

      it 'returns Array given Array' do
        s = [1, 2]
        expect(Types.seq(s)).to equal(s)
      end

      it 'coerces non-map enumerable to Array' do
        expect(Types.seq(Set.new(['a']))).to eq(['a'])
      end

      it 'returns nil for maps' do
        expect(Types.seq({})).to be_nil
      end
    end

    describe '.string' do
      it 'returns nil given nil' do
        expect(Types.string(nil)).to be_nil
      end

      it 'coerces primitives' do
        expect(Types.string(1)).to eq('1')
        expect(Types.string(1.0)).to eq('1.0')
        expect(Types.string(true)).to eq('true')
        expect(Types.string(false)).to eq('false')
      end

      it 'returns input given string' do
        expect(Types.string('foo')).to eq('foo')
      end

      it 'returns nil given non primitive' do
        expect(Types.string({})).to be_nil
        expect(Types.string([])).to be_nil
      end
    end
  end
end

