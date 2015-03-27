require 'offs/flags'

describe OFFS::Flags do
  context 'when no value sources are defined' do
    before(:each) do
      subject.define_flags :my_flag, :my_other_flag, :your_flag, :your_other_flag
    end

    it 'raises an UndefinedFlagError when asked for an undefined flag status' do
      expect {
        subject.enabled?(:an_undefined_flag)
      }.to raise_error(described_class::UndefinedFlagError,
                       "The an_undefined_flag flag has not been defined.")
    end

    it 'says that flags are disabled' do
      [:my_flag, :my_other_flag, :your_flag, :your_other_flag].each do |flag|
        expect(subject.enabled?(flag)).to eq false
      end
    end
  end
end
