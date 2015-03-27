require "offs/version"
require 'offs/flags'
require 'injectable_dependencies'

class OFFS
  include InjectableDependencies

  class FeatureDisabled < RuntimeError; end

  class << self
    def so_you_want_to(flag, &block)
      new(flag).so_you_want_to(&block)
    end

    def if_you_would_like_to(flag, &block)
      so_you_want_to(flag) do |you|
        you.would_like_to(&block)
      end
    end

    def if_you_do_not_want_to(flag, &block)
      so_you_want_to(flag) do |you|
        you.may_still_need_to(&block)
      end
    end

    def raise_error_unless_we(flag)
      new(flag).raise_error_unless_we
    end

    def feature_flags
      Flags.instance.to_a
    end
  end

  dependency(:feature_flags) { Flags.instance }

  def initialize(flag, options={})
    initialize_dependencies options[:dependencies]
    self.flag = flag
  end

  def so_you_want_to(&block)
    block.call(self)
    return result
  end

  def would_like_to(&block)
    when_flag(true, &block)
  end

  def may_still_need_to(&block)
    when_flag(false, &block)
  end

  def raise_error_unless_we
    unless flag_enabled?
      raise FeatureDisabled,
        "Attempted to access code that is only available when the '#{flag}' " \
        + "feature is enabled, and it is currenlty disabled."
    end
  end

  private

  attr_accessor :flag
  attr_accessor :result

  def when_flag(bool, &block)
    self.result = block.call if flag_status == bool
  end

  def flag_status
    feature_flags.enabled?(flag)
  end
  alias_method :flag_enabled?, :flag_status
end
