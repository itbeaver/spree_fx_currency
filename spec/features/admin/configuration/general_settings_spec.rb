describe 'General Settings', type: :feature do
  stub_authorization!

  before(:each) do
    create(:store, name: 'Test Store', url: 'test.example.org',
                   mail_from_address: 'test@example.org')
    visit spree.edit_admin_general_settings_path
  end

  context 'editing general settings (admin)' do
    let(:currencies) { 'USD, EUR, GBP' }
    let(:field_name) { 'supported_currencies' }

    it 'should create FxRate after changing supported_currencies' do
      fill_in name: field_name, with: currencies
      click_button 'Update'

      expect(find_field(name: field_name).value).to eq(currencies)

      expect(Spree::FxRate.count).to eq(2)
    end
  end
end
