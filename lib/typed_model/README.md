# Ruby Data Modeling Lib

Document and validate structure via Class hierarchy primarily for feeding/consuming APIs (e.g. JSON).

* data mapping (data -> object -> data)
* declared types
* declared validations
* Nested models
    
##
    Employee
      include DataModelBase

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
