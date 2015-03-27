require 'offs/flags'

describe OFFS::Flags do
  context 'when no value sources are defined' do
    it 'raises an UndefinedFlagError when asked for an undefined flag status' do
      expect {
        subject.enabled?(:an_undefined_flag)
      }.to raise_error(described_class::UndefinedFlagError,
                       "The an_undefined_flag flag has not been defined.")
    end
  end
end
