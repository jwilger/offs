require 'spec_helper'

describe OFFS do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  subject { described_class.new(flag, flag_status_checker: flag_status_checker) }

  let(:flag) { :use_my_new_feature }

  let(:flag_status_checker) { double(:flag_status_checker, validate!: nil) }

  context 'when the specified feature flag is not defined' do
    it 'raises an error' do
      allow(flag_status_checker).to receive(:validate!).with(flag) do
        raise described_class::UndefinedFlagError, "Some message"
      end
      expect{ subject.would_like_to {} }.to \
        raise_error(described_class::UndefinedFlagError, "Some message")
    end
  end

  context "when the specified feature flag is defined" do
    let(:would_like_to_blk) { ->{ :would_like_to_happened } }
    let(:may_still_need_to_blk) { ->{ :may_still_need_to_happened } }

    def do_it
      subject.so_you_want_to do |you|
        you.would_like_to(&would_like_to_blk)
        you.may_still_need_to(&may_still_need_to_blk)
      end
    end

    def do_it_backwards
      subject.so_you_want_to do |you|
        you.may_still_need_to(&may_still_need_to_blk)
        you.would_like_to(&would_like_to_blk)
      end
    end

    context "and the feature is turned on by default" do
      before(:each) do
        allow(flag_status_checker).to receive(:enabled?).with(flag) \
          .and_return(true)
      end

      it 'executes the would_like_to block' do
        expect(would_like_to_blk).to receive(:call)
        do_it
      end

      it 'does not execute the may_still_need_to block' do
        expect(may_still_need_to_blk).to_not receive(:call)
        do_it
      end

      it 'returns the value of the would_like_to block' do
        expect(do_it).to eq :would_like_to_happened
        expect(do_it_backwards).to eq :would_like_to_happened
      end

      it 'will execute the block for if_you_would_like_to' do
        x = nil
        OFFS.if_you_would_like_to(:use_my_new_feature,
                                  flag_status_checker: flag_status_checker) do
          x = 1
        end
        expect(x).to eq 1
      end

      it 'will not execute the block for if_you_do_not_want_to' do
        x = nil
        OFFS.if_you_do_not_want_to(:use_my_new_feature,
                                   flag_status_checker: flag_status_checker) do
          x = 1
        end
        expect(x).to be_nil
      end

      it 'noops for raise_error_unless_we' do
        OFFS.raise_error_unless_we(:use_my_new_feature,
                                   flag_status_checker: flag_status_checker)
      end
    end

    context "and the feature is turned off by default" do
      before(:each) do
        allow(flag_status_checker).to receive(:enabled?).with(flag) \
          .and_return(false)
      end


      it "executes the may_still_need_to block" do
        expect(may_still_need_to_blk).to receive(:call)
        do_it
      end

      it 'does not execute the would_like_to block' do
        expect(would_like_to_blk).to_not receive(:call)
        do_it
      end

      it 'returns the value of the may_still_need_to block' do
        expect(do_it).to eq :may_still_need_to_happened
        expect(do_it_backwards).to eq :may_still_need_to_happened
      end

      it 'will not execute the block for if_you_would_like_to' do
        x = nil
        OFFS.if_you_would_like_to(:use_my_new_feature,
                                  flag_status_checker: flag_status_checker) do
          x = 1
        end
        expect(x).to be_nil
      end

      it 'will execute the block for if_you_do_not_want_to' do
        x = nil
        OFFS.if_you_do_not_want_to(:use_my_new_feature,
                                   flag_status_checker: flag_status_checker) do
          x = 1
        end
        expect(x).to eq 1
      end

      it 'raises an OFFS::FeatureDisabled error for raise_error_unless_we' do
        expect {
          OFFS.raise_error_unless_we(:use_my_new_feature,
                                     flag_status_checker: flag_status_checker)
        }.to raise_error(OFFS::FeatureDisabled, /use_my_new_feature/)
      end
    end
  end
end
