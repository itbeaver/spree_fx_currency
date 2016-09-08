RSpec.describe Spree::FxRate, type: :model do
  subject { described_class.new }

  it('#value') { expect(subject).to respond_to(:value) }
  it('#currency') { expect(subject).to respond_to(:currency) }
end
