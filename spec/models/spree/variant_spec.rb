RSpec.describe Spree::Variant, type: :model do
  let!(:variant) { create(:variant) }

  describe '.price_in' do
    before do
      variant.prices << create(:price, :variant => variant, :currency => "EUR", :amount => 33.33)
    end
    subject { variant.price_in(currency).display_amount }

    context "when currency is not specified" do
      let(:currency) { nil }

      it "returns 0" do
        expect(subject.to_s).to eql "$0.00"
      end
    end

    context "when currency is EUR" do
      let(:currency) { 'EUR' }

      it "returns the value in the EUR" do
        expect(subject.to_s).to eql "€33.33"
      end
    end

    context "when currency is USD" do
      let(:currency) { 'USD' }

      it "returns the value in the USD" do
        expect(subject.to_s).to eql "$19.99"
      end
    end
  end

  describe '.amount_in' do
    before do
      variant.prices << create(:price, :variant => variant, :currency => "EUR", :amount => 33.33)
    end

    subject { variant.amount_in(currency) }

    context "when currency is not specified" do
      let(:currency) { nil }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when currency is EUR" do
      let(:currency) { 'EUR' }

      it "returns the value in the EUR" do
        expect(subject).to eql 33.33
      end
    end

    context "when currency is USD" do
      let(:currency) { 'USD' }

      it "returns the value in the USD" do
        expect(subject).to eql 19.99
      end
    end
  end
end
