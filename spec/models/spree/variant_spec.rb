describe Spree::Variant, type: :model do
  context 'when fx rates is present' do
    let!(:to_eur) { create(:fx_rate, to_currency: 'EUR', rate: 0.884791322) }
    let!(:product) { create(:product, price: 10.00) }
    let!(:variant) { create(:variant, product: product, price: 5.00) }

    context 'when create new variant' do
      it 'prices created for new variant' do
        variants_ids = product.variants_including_master.pluck(:id)
        prices = Spree::Price.where(variant_id: variants_ids).order(:id)
                             .map { |p| [p.currency, p.display_amount.to_s] }

        expect(prices).to eq(
          [
            ['USD', '$10.00'], ['EUR', '€8.85'],
            ['USD', '$5.00'], ['EUR', '€4.42']
          ]
        )

        create(:variant, product: product, price: 15.00)

        variants_ids = product.variants_including_master.pluck(:id)
        prices = Spree::Price.where(variant_id: variants_ids).order(:id)
                             .map { |p| [p.currency, p.display_amount.to_s] }

        expect(prices).to eq(
          [
            ['USD', '$10.00'], ['EUR', '€8.85'],
            ['USD', '$5.00'], ['EUR', '€4.42'],
            ['USD', '$15.00'], ['EUR', '€13.27']
          ]
        )
      end
    end
  end
end
