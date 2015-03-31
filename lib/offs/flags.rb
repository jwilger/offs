require 'delegate'
require 'offs/exceptions'

class OFFS
  class Flags < DelegateClass(Array)
    class << self
      private :new
      
      def instance(*args)
        unless @instance.nil? || args.empty?
          raise AlreadyInitializedError
        end
        @instance ||= new(*args)
      end

      def reset_instance!
        @instance = nil
      end
    end

    def initialize(*flags, value_sources: {})
      self.value_sources = array_wrap(value_sources)
      __setobj__(flags)
    end

    def validate!(flag)
      return true if include?(flag)
      raise UndefinedFlagError, "The #{flag} flag has not been defined."
    end

    def enabled?(flag)
      validate!(flag)
      !!final_values[flag]
    end

    private

    attr_accessor :value_sources

    def array_wrap(obj)
      return [obj] unless obj.kind_of?(Array)
      obj
    end

    def final_values
      value_sources.reverse.reduce({}) { |final, source|
        final.merge(sanitize(source))
      }
    end

    def sanitize(data_hash)
      data_hash.reduce({}) { |result, k_v_pair|
        key = k_v_pair.first.to_s.downcase.to_sym
        value = [true, 'true', 1, '1', 'on'].include?(k_v_pair.last)
        result[key] = value
        result
      }
    end
  end
end
