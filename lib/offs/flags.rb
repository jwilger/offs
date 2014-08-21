class OFFS
  class Flags
    UndefinedFlagError = Class.new(StandardError)

    class << self
      def instance
        @instance ||= new
      end

      def set(&block)
        block.call(instance)
        instance
      end
    end

    def flag(name, default)
      env_var_name = name.to_s.upcase
      feature_flags[name] = if ENV.has_key?(env_var_name)
                              ENV[env_var_name].strip == '1'
                            else
                              default
                            end
    end

    def feature_flags
      @feature_flags ||= {}
    end

    def enabled?(flag)
      !!feature_flags[flag]
    end

    def valid?(flag)
      feature_flags.has_key?(flag)
    end

    def validate!(flag)
      if valid?(flag)
        flag
      else
        raise UndefinedFlagError, "The #{flag} flag has not been defined."
      end
    end
  end
end
