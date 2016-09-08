RSpec.describe Spree::FxRate, type: :model do
  subject { described_class.new }

  it('#rate') { expect(subject).to respond_to(:rate) }
  it('#from_currency') { expect(subject).to respond_to(:from_currency) }
  it('#to_currency') { expect(subject).to respond_to(:to_currency) }

  context '.create_supported_currencies' do
    subject { described_class }

    before(:each) { Spree::Config.supported_currencies = 'USD, EUR' }

    it 'creates currencies from spree-multi-currency gem' do
      expect { subject.create_supported_currencies }.to change { subject.count }
    end
  end

  context '#update_all_prices' do
    let(:fx_rate) do
      described_class.new(
        from_currency: 'USD', to_currency: 'EUR', rate: 0.884791322
      )
    end

    context 'when prices with currency=to_currency exists' do
      let!(:from_price) { create(:price, currency: 'USD', amount: 10.00) }
      let!(:to_price) { create(:price, currency: 'EUR', amount: 5.00) }

      subject { to_price.display_amount }

      it 'updates prices using from_currency price and rate' do
        expect { fx_rate.update_all_prices }.to change { subject.to_s }
          .from('€5.00').to('€8.85')
      end
    end

    context 'when prices with currency=to_currency not exists' do
      let!(:from_price) { create(:price, currency: 'USD', amount: 10.00) }

      it 'creates prices using from_currency price and rate' do
        variant_prices = from_price.variant.prices
        expect { fx_rate.update_all_prices }.to change { variant_prices.count }
          .from(0).to(1)

        expect { fx_rate.update_all_prices }.to change do
          price = variant_prices.find_by(currency: fx_rate.to_currency)
          price.try(:display_amount).to_s
        end.from('').to('€8.85')
      end
    end
  end
end
