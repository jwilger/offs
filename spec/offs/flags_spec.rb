require 'offs/flags'

describe OFFS::Flags do
  subject {
    # Must use #send, because it is usually a Singleton, but we want seperate
    # objects for testing.
    described_class.send(:new, :use_feature_a, :use_feature_b, :use_feature_c,
                         value_sources: value_sources)
  }

  let(:value_sources) {{}}

  it 'acts like an Array of all defined flag names' do
    expect(subject).to eq [:use_feature_a, :use_feature_b, :use_feature_c]
  end

  it 'provides singleton behavior' do
    expect(described_class.instance).to be_kind_of(described_class)
    expect(described_class.instance).to be described_class.instance
  end

  it 'allows flags and value_sources to be defined when the instance is ' \
   + 'first created' do
    described_class.reset_instance!
    instance = described_class.instance(:foo, :bar, :baz)
    expect(instance).to eq [:foo, :bar, :baz]
  end

  it 'raises an AlreadyInitializedError when #instance is called with ' \
   + 'arguments on subsequent calls' do
    described_class.reset_instance!
    described_class.instance(:foo)
    expect {
      described_class.instance(:foo)
    }.to raise_error(OFFS::AlreadyInitializedError)
  end

  context 'when a flag has not been defined' do
    it 'raises an exception when asked to validate the flag' do
      expect{
        subject.validate!(:flag_that_is_not_defined)
      }.to raise_error(OFFS::UndefinedFlagError,
                       /flag_that_is_not_defined/)
    end

    it 'raises an exception when asked for the status of the flag' do
      expect{
        subject.enabled?(:flag_that_is_not_defined)
      }.to raise_error(OFFS::UndefinedFlagError,
                       /flag_that_is_not_defined/)
    end
  end

  context 'when a flag has been defined' do
    it 'returns true when asked to validate the flag' do
      expect(subject.validate!(:use_feature_a)).to eq true
    end

    context 'when no value sources are defined' do
      it 'assumes the flag is disabled' do
        expect(subject.enabled?(:use_feature_a)).to eq false
      end
    end

    context 'when one value source is defined' do
      let(:value_sources) { [source_a] }

      let(:source_a) {Hash.new}

      context 'and the flag is set in the value source' do
        shared_examples_for 'it determines flag status based on value source when' do |source_key|
          let(:source_a) {{
            source_key => true,
          }}

          it "has a value source with a key of #{source_key.inspect}" do
            expect(subject.enabled?(:use_feature_a)).to eq true
          end
        end

        it_behaves_like 'it determines flag status based on value source when',
          :use_feature_a

        it_behaves_like 'it determines flag status based on value source when',
          'use_feature_a'

        it_behaves_like 'it determines flag status based on value source when',
          'USE_FEATURE_A'

        shared_examples_for "it has a true value when" do |value|
          it "the value source is set to #{value.inspect}" do
            source_a[:use_feature_a] = value
            expect(subject.enabled?(:use_feature_a)).to eq true
          end
        end

        it_behaves_like 'it has a true value when', 'true'
        it_behaves_like 'it has a true value when', '1'
        it_behaves_like 'it has a true value when', 'on'
        it_behaves_like 'it has a true value when', 1

        shared_examples_for "it has a false value when" do |value|
          it "the value source is set to #{value.inspect}" do
            source_a[:use_feature_a] = value
            expect(subject.enabled?(:use_feature_a)).to eq false
          end
        end

        it_behaves_like 'it has a false value when', 'false'
        it_behaves_like 'it has a false value when', '0'
        it_behaves_like 'it has a false value when', 'off'
        it_behaves_like 'it has a false value when', 0
      end

      context 'and the flag is not set in the value source' do
        let(:source_a) {{
          :use_feature_b => true,
        }}

        it 'assumes the flag is disabled' do
          expect(subject.enabled?(:use_feature_a)).to eq false
        end
      end
    end

    context 'when multiple value sources are defined' do
      let(:value_sources) { [source_c, source_b, source_a] }
      let(:source_a) {{
        :use_feature_a => true,
        :use_feature_b => false,
        :use_feature_c => true
      }}

      let(:source_b) {{
        'USE_FEATURE_B' => true
      }}

      let(:source_c) {{
        'use_feature_c' => false
      }}

      it 'determines whether the flag is enabled based on the first value ' \
       + 'source in which the flag value is set' do
        expect(subject.enabled?(:use_feature_a)).to eq true
        expect(subject.enabled?(:use_feature_b)).to eq true
        expect(subject.enabled?(:use_feature_c)).to eq false
      end

      it 'recalculates status if the value source changes state' do
        expect(subject.enabled?(:use_feature_c)).to eq false
        source_c[:use_feature_c] = true
        expect(subject.enabled?(:use_feature_c)).to eq true
      end
    end
  end
end
