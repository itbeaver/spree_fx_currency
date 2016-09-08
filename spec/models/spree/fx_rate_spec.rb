RSpec.describe Spree::FxRate, type: :model do
  subject { described_class.new }

  it('#value') { expect(subject).to respond_to(:value) }
  it('#currency') { expect(subject).to respond_to(:currency) }

  context '.create_supported_currencies' do
    subject { described_class }

    before(:each) { Spree::Config.supported_currencies = 'USD, EUR' }

    it 'creates currencies from spree-multi-currency gem' do
      expect { subject.create_supported_currencies }.to change { subject.count }
    end
  end
end
