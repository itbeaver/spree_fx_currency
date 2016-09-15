RSpec.describe Spree::FxRate, type: :model do
  it('#rate') { is_expected.to respond_to(:rate) }
  it('#from_currency') { is_expected.to respond_to(:from_currency) }
  it('#to_currency') { is_expected.to respond_to(:to_currency) }

  context 'when fx rates is blank' do
    context '.create_supported_currencies' do
      subject { described_class }

      before(:each) { Spree::Config.supported_currencies = 'USD, EUR' }

      it 'creates currencies from spree-multi-currency gem' do
        expect { subject.create_supported_currencies }.to(
          change { subject.count }
        )
      end
    end
  end

  context 'when fx rates created' do
    let!(:to_eur) { create(:fx_rate, to_currency: 'EUR', rate: 1.0) }

    context '#update_products_prices' do
      subject { to_eur }

      context 'when product has only master variant' do
        context 'when prices with currency=to_currency exists' do
          let!(:product) { create(:product, price: 10.00) }
          let(:variant) { product.master }
          let!(:to_price) do
            Spree::Price.find_by(variant_id: variant.id, currency: 'EUR')
          end

          it 'updates prices using from_currency price and rate' do
            to_eur.update_column(:rate, 0.884791322)

            expect { subject.update_products_prices }.to change {
              to_price.reload.display_amount.to_s
            }.from('€10.00').to('€8.85')
          end
        end

        context 'when prices with currency=to_currency not exists' do
          let!(:product) { create(:product, price: 10.00) }
          let(:variant) { product.master }

          it 'creates prices using from_currency price and rate' do
            to_eur.update_column(:rate, 0.884791322)

            variant_prices = variant.prices

            expect { subject.update_products_prices }.to change {
              variant_prices.find_by(currency: subject.to_currency)
                            .try(:display_amount).to_s
            }.from('€10.00').to('€8.85')
          end
        end
      end

      context 'when product has_many variants' do
        context 'when prices with currency=to_currency not exists' do
          let!(:product) { create(:product, price: 10.00) }
          let(:master_variant) { product.master }
          let!(:variant) { create(:variant, product: product, price: 10.00) }

          it 'creates variants prices using from_currency price and rate' do
            to_eur.update_column(:rate, 0.884791322)

            variant_prices = variant.reload.prices

            expect { subject.update_products_prices }.to change {
              variant_prices.reload.find_by(currency: subject.to_currency)
                            .try(:display_amount).to_s
            }.from('').to('€8.85')
          end
        end
      end
    end

    context 'stub fixer' do
      let(:fixer_symbols) { 'EUR' }
      before(:each) do
        stub_request(
          :get,
          "http://api.fixer.io/latest?base=USD&symbols=#{fixer_symbols}"
        ).to_return(response_file)
      end

      context 'when to fixer passed one symbol' do
        let!(:response_file) { File.new('./spec/support/api/fixer.txt') }

        context '#fetch_fixer' do
          subject { to_eur }

          it 'updates rate' do
            expect { subject.fetch_fixer }.to change { subject.rate }
              .from(1.0).to(0.89079)
          end
        end
      end

      context 'when to fixer passed many symbols' do
        let!(:fixer_symbols) { 'EUR,GBP' }
        let!(:to_gbp) { create(:fx_rate, to_currency: 'GBP') }
        let!(:response_file) { File.new('./spec/support/api/fixer_many.txt') }

        context '.fetch_fixer' do
          subject { described_class }

          it 'not raises error' do
            expect { subject.fetch_fixer }.not_to raise_error
          end

          it 'updates all rates' do
            expect { subject.fetch_fixer }.to(
              change { subject.order(:to_currency).pluck(:to_currency, :rate) }
              .from([['EUR', 1.0], ['GBP', 1.0]])
              .to([['EUR', 0.89079], ['GBP', 0.75249]])
            )
          end
        end
      end
    end
  end
end
