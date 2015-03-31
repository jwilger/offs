require 'delegate'

class OFFS
  class Permutations < DelegateClass(Enumerator)
    def initialize(flags: Flags.instance)
      self.flags = flags
      __setobj__ create_permutations
    end

    private

    attr_accessor :flags

    def create_permutations
      permutations = [true,false].repeated_permutation(flags.size).map { |values|
        flags.zip(values).inject({}) { |m, pair|
          m[pair[0]] = pair[1]
          m
        }
      }
      permutations.each
    end
  end
end
