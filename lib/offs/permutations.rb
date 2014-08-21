require 'delegate'
require 'injectable_dependencies'

class OFFS
  class Permutations < DelegateClass(Enumerator)
    include InjectableDependencies

    dependency(:flags) { Flags.instance }

    def initialize(options={})
      initialize_dependencies(options[:dependencies])
      __setobj__ create_permutations
    end

    private

    def create_permutations
      keys = flags.to_a
      permutations = [true,false].repeated_permutation(keys.size).map { |values|
        keys.zip(values).inject({}) { |m, pair|
          m[pair[0]] = pair[1]
          m
        }
      }
      permutations.each
    end
  end
end
