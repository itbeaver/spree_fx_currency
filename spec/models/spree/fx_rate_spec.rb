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

    context 'only master price' do
      context 'when prices with currency=to_currency exists' do
        let!(:product) { create(:product, price: 10.00) }
        let(:variant) { product.master }
        let(:from_price) { master.price }
        let!(:to_price) do
          create(:price, currency: 'EUR', amount: 5.0, variant: variant)
        end

        it 'updates prices using from_currency price and rate' do
          expect { fx_rate.update_all_prices }.to change {
            to_price.reload.display_amount.to_s
          }.from('€5.00').to('€8.85')
        end
      end

      context 'when prices with currency=to_currency not exists' do
        let!(:product) { create(:product, price: 10.00) }
        let(:variant) { product.master }
        let(:from_price) { master.price }

        it 'creates prices using from_currency price and rate' do
          variant_prices = variant.prices

          expect { fx_rate.update_all_prices }.to change {
            variant_prices.find_by(currency: fx_rate.to_currency)
                          .try(:display_amount).to_s
          }.from('').to('€8.85')
        end
      end
    end

    context 'when product have variants' do
      context 'when prices with currency=to_currency not exists' do
        let!(:product) { create(:product, price: 10.00) }
        let(:master_variant) { product.master }
        let!(:variant) { create(:variant, product: product, price: 10.00) }
        let(:from_price) { master.price }

        it 'creates variants prices using from_currency price and rate' do
          variant_prices = variant.reload.prices

          expect { fx_rate.update_all_prices }.to change {
            variant_prices.reload.find_by(currency: fx_rate.to_currency)
                          .try(:display_amount).to_s
          }.from('').to('€8.85')
        end
      end
    end
  end
end
