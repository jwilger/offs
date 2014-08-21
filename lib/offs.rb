require "offs/version"
require 'injectable_dependencies'

class OFFS
  include InjectableDependencies

  UndefinedFlagError = Class.new(StandardError)

  class << self
    def so_you_want_to(flag, &block)
      new(flag).so_you_want_to(&block)
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
  end

  dependency(:feature_flags) { OFFS.feature_flags }

  def initialize(flag, options={})
    initialize_dependencies options[:dependencies]
    self.flag = flag
  end

  def so_you_want_to(&block)
    block.call(self)
  end

  def would_like_to(&block)
    return unless flag_is_on?
    block.call
  end

  def may_still_need_to(&block)
    return if flag_is_on?
    block.call
  end

  private

  attr_reader :flag

  def flag_is_on?
    !!feature_flags[flag]
  end

  def flag=(new_flag)
    if feature_flags.has_key?(new_flag)
      @flag = new_flag
    else
      raise UndefinedFlagError, "The #{new_flag} flag has not been defined."
    end
  end
end
