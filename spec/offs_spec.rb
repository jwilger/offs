require 'spec_helper'

describe OFFS do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  subject { described_class.new(flag, dependencies: dependencies) }

  let(:flag) { :my_cool_new_feature }

  let(:dependencies) {{
    feature_flags: feature_flags
  }}

  let(:feature_flags) {{
    :my_cool_new_feature => feature_status
  }}

  let(:feature_status) { true }

  context 'when the specified feature flag is not defined' do
    let(:feature_flags) {{}}

    it 'raises an error' do
      expect{ subject.so_you_want_to {} }.to \
        raise_error(OFFS::UndefinedFlagError,
                    "The #{flag} flag has not been defined.")
    end
  end

  context "when the specified feature flag is defined" do
    let(:would_like_to_blk) { ->{} }
    let(:may_still_need_to_blk) { ->{} }

    after(:each) do
      subject.so_you_want_to do |you|
        you.would_like_to(&would_like_to_blk)
        you.may_still_need_to(&may_still_need_to_blk)
      end
    end

    context "and the feature is turned on by default" do
      it 'executes the would_like_to block' do
        expect(would_like_to_blk).to receive(:call)
      end
      it 'does not execute the may_still_need_to block' do
        expect(may_still_need_to_blk).to_not receive(:call)
      end
    end

    context "and the feature is turned off by default" do
      let(:feature_status) { false }

      it "executes the may_still_need_to block" do
        expect(may_still_need_to_blk).to receive(:call)
      end
      it 'does not execute the would_like_to block' do
        expect(would_like_to_blk).to_not receive(:call)
      end
    end
  end
end
