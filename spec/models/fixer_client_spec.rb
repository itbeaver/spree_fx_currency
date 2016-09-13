RSpec.describe FixerClient, type: :model do
  context '#fetch' do
    context 'when request not raise an error' do
      before(:each) do
        fsymbols = fixer_symbols.join(',')
        stub_request(
          :get,
          "http://api.fixer.io/latest?base=USD&symbols=#{fsymbols}"
        ).to_return(response_file)
      end

      context 'has one symbol' do
        let!(:fixer_symbols) { ['EUR'] }
        let!(:response_file) { File.new('./spec/support/api/fixer.txt') }
        subject { described_class.new('USD', fixer_symbols) }

        it('returns rate') { expect(subject.fetch).to eq(0.89079) }
      end
      context 'has many symbols' do
        let!(:fixer_symbols) { %w(EUR GBP) }
        let!(:response_file) { File.new('./spec/support/api/fixer_many.txt') }
        subject { described_class.new('USD', fixer_symbols) }

        it 'returns rates' do
          expect(subject.fetch).to eq(
            'GBP' => 0.75249,
            'EUR' => 0.89079
          )
        end
      end
    end

    context 'when request raise an error' do
      before(:each) do
        allow(Net::HTTP).to receive(:get).and_raise(Net::HTTPBadResponse)
      end

      let!(:fixer_symbols) { ['EUR'] }
      subject { described_class.new('USD', fixer_symbols) }

      it('return nil') { expect(subject.fetch).to eq(nil) }
    end
  end
end
