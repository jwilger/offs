require "offs/version"
require "offs/flags"
require 'offs/exceptions'

class OFFS
  class << self
    def so_you_want_to(flag, flag_status_checker: nil, &block)
      new(flag, flag_status_checker: flag_status_checker).so_you_want_to(&block)
    end

    def if_you_would_like_to(flag, flag_status_checker: nil, &block)
      so_you_want_to(flag, flag_status_checker: flag_status_checker) do |you|
        you.would_like_to(&block)
      end
    end

    def if_you_do_not_want_to(flag, flag_status_checker: nil, &block)
      so_you_want_to(flag, flag_status_checker: flag_status_checker) do |you|
        you.may_still_need_to(&block)
      end
    end

    def raise_error_unless_we(flag, flag_status_checker:)
      new(flag, flag_status_checker: flag_status_checker) \
        .raise_error_unless_we
    end
  end

  def initialize(flag, flag_status_checker: nil)
    self.flag_status_checker = flag_status_checker || Flags.instance
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

  attr_reader :flag
  attr_accessor :result, :flag_status_checker

  def flag=(new_flag)
    flag_status_checker.validate!(new_flag)
    @flag = new_flag
  end

  def when_flag(bool, &block)
    self.result = block.call if flag_enabled? == bool
  end

  def flag_enabled?
    flag_status_checker.enabled?(flag)
  end
end
