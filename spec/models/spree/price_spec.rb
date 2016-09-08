RSpec.describe Spree::Price, type: :model do
  let!(:price) { create(:price, currency: 'USD', amount: 10.00) }

  context '#amount' do
    subject { price.display_amount }

    context 'when FX rate is not set' do
      context 'when currency is EUR' do
        before(:each) { price.currency = 'EUR' }

        it 'returns the value in the EUR' do
          expect(subject.to_s).to eql '€10.00'
        end
      end

      context 'when currency is USD' do
        before(:each) { price.currency = 'USD' }

        it 'returns the value in the USD' do
          expect(subject.to_s).to eql '$10.00'
        end
      end
    end

    xcontext 'when FX rate is set' do
      before(:each) do
        Spree::Config.supported_currencies = 'USD, EUR'
        Spree::FxRate.create_supported_currencies
        Spree::FxRate.find_by(currency: 'EUR').update_attributes(value: 0.887)
      end

      context 'when currency is EUR' do
        before(:each) { price.currency = 'EUR' }

        it 'returns the value in the EUR' do
          expect(subject.to_s).to eql '€8.87'
        end
      end

      context 'when currency is USD' do
        before(:each) { price.currency = 'USD' }

        it 'returns the value in the USD' do
          expect(subject.to_s).to eql '$10.00'
        end
      end
    end
  end
end
