describe Spree::Product, type: :model do
  context 'when fx rates is present' do
    let!(:to_eur) { create(:fx_rate, to_currency: 'EUR', rate: 0.884791322) }

    context 'clone product' do
      let(:product) { create(:product, price: 10.00) }
      let(:variant) { create(:variant, product: product) }

      it 'prices created for new product' do
        variants_ids = product.variants_including_master.pluck(:id)
        prices = Spree::Price.where(
          variant_id: variants_ids
        ).order(:id).pluck(:currency, :amount)

        clone = product.duplicate

        clone_variants_ids = clone.variants_including_master.pluck(:id)
        clone_prices = Spree::Price.where(
          variant_id: clone_variants_ids
        ).order(:id).pluck(:currency, :amount)

        expect(clone_prices).to eq(prices)
      end
    end

    context 'when create new product' do
      let(:product) { create(:product, price: 10.00) }
      let(:variant) { create(:variant, product: product) }

      it 'prices created for new product' do
        variants_ids = product.variants_including_master.pluck(:id)
        prices = Spree::Price.where(variant_id: variants_ids).order(:id)
                             .map { |p| [p.currency, p.display_amount.to_s] }

        expect(prices).to eq(
          [['USD', '$10.00'], ['EUR', '€8.85']]
        )
      end
    end
  end
end
