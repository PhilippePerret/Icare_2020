# encoding: UTF-8
# frozen_string_literal: true

describe String do
  before(:all) do
    require './_lib/required/__first/extensions/String.rb'
  end

  describe 'safe_path' do
    it 'existe' do
      expect(String).to respond_to :safe_path
    end
    it 'retourne le nom de fichier s’est est "pur"' do
      expect(String.safe_path('mon_nom_pur.com')).to eq 'mon_nom_pur.com'
    end
    it 'retourne un nom de fichier "pur"' do
      expect(String.safe_path('çac’estl’été.com')).to eq("@ac@estl@@t@.com")
    end
  end
end
