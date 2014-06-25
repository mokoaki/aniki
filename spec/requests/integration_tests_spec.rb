require 'rails_helper'

describe "IntegrationTests", :type => :request do
  context 'root_path' do
    it 'visit' do
      visit root_path
      expect(page).to have_content('ログインID')
    end

    it 'ログイン' do
      pending 'a'
      a
    end
  end
end
