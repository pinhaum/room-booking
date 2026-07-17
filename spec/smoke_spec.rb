require 'rails_helper'

# Baseline sanity checks for the Phase 0 foundation.
RSpec.describe 'application foundation' do
  it 'defaults the locale to Brazilian Portuguese' do
    expect(I18n.default_locale).to eq(:"pt-BR")
  end

  it 'uses the São Paulo time zone' do
    expect(Rails.application.config.time_zone).to eq('America/Sao_Paulo')
  end
end
