# TypedModel

A Ruby library for defining data schemas via classes with 
typed fields and built in hydration and serialization

* data mapping (data -> object -> data)
* declared types
* declared validations
* Nested models
    
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typed_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typed_model

## Usage

    Employee
      include ModelBase

      attribute :a_boolean, type: :boolean
      attribute :an_integer, type: :integer
      attribute :a_timestamp, type: :timestamp
      attribute :widget1, type: :map
      attribute :address, type: a_c
      attribute :addresses, seq_of: a_c
      attribute :colors, type: :seq
    end
        
### Sequences
    
      # non-empty/nil sequence
      attribute :a_seq, type: :seq, :validations [:required]
      
      attribute :a_seq, seq_of: :string
      
      attribute :a_seq, seq_of: Address
      
      # sequence of string -> integer maps
      attribute :a_Seq, seq_of: [:string, :integer]
      
      attribute :a_seq, seq_of: { type: Adress, :validations [:some_validation] }
        
### Maps

      # string -> string
      attribute :a_map, :map_of [:string, :integer]
      
      attribute :a_map, type: :map, validations: [:required]
      
      # map of maps
      attribute :map_of_maps, :map_of [:string, [:string, :integer]]
      
      # map of maps
      attribute :a_map, :map_of [{type: :string, validators: [:some_check]},
                                 {type: Address, validators: [:required]},
                        :validators [:required]

### Validations

Primitive types (e.g. :string, :integer, :timestamp, :boolean, etc) are 
automatically validated.

##### Custom validations

Via :keyword or `Validator instance`
 
        class Employee
            ...
            attribute :name, validations: [:my_validation]

            def assert_my_validation(attr)
              add_error(attr, 'some error')
            end
         end
         

        validator = Validator.new(:foo) do
           ['some error']
        end
        
        class Employee
           ...
           attribute :name, validations: [validator]


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/typed_model.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
