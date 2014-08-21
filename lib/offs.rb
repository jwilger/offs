require "offs/version"
require 'offs/flags'
require 'injectable_dependencies'

class OFFS
  include InjectableDependencies

  class << self
    def so_you_want_to(flag, &block)
      new(flag).so_you_want_to(&block)
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
  end

  def would_like_to(&block)
    when_flag(true, &block)
  end

  def may_still_need_to(&block)
    when_flag(false, &block)
  end

  private

  attr_reader :flag

  def when_flag(bool, &block)
    block.call if flag_status == bool
  end

  def flag_status
    feature_flags.enabled?(flag)
  end

  def flag=(new_flag)
    @flag = feature_flags.validate!(new_flag)
  end
end
