require 'spec_helper'
require 'offs/permutations'

describe OFFS::Permutations do
  subject { described_class.new(dependencies: dependencies) }

  let(:dependencies) {{
    flags: flags
  }}

  let(:flags) { double(:flags, to_a: [:feature_a, :feature_b, :feature_c]) }

  let(:possible_permutations) {[
    { feature_a: true,  feature_b: true,  feature_c: true  },
    { feature_a: false, feature_b: true,  feature_c: true  },
    { feature_a: true,  feature_b: false, feature_c: true  },
    { feature_a: true,  feature_b: true,  feature_c: false },
    { feature_a: false, feature_b: false, feature_c: true  },
    { feature_a: false, feature_b: true,  feature_c: false },
    { feature_a: true,  feature_b: false, feature_c: false },
    { feature_a: false, feature_b: false, feature_c: false },
  ]}

  let(:receiver) { double(:receiver) }

  it 'yields every permutation of feature flag combinations' do
    possible_permutations.each do |permutation|
      expect(receiver).to receive(:flags).with(permutation)
    end

    subject.each do |flags|
      receiver.flags(flags)
    end
  end
end
