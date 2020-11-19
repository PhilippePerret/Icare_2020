# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour tester la liste des icariens
=end
require_relative './_required'

def absmodule_names
  @abs
end #/ absmodule_names

def icariens_actifs
  @icariens_actifs ||= begin
    request = <<-SQL
SELECT
  u.*,
  amods.name AS module_name
  FROM users u
  INNER JOIN icmodules icmods ON u.icmodule_id = icmods.id
  INNER JOIN absmodules amods ON icmods.absmodule_id = amods.id
  WHERE SUBSTRING(u.options,17,1) = '2'
    SQL
    db_exec(request)
  end
end #/ icariens_actifs

def admins
  @admins ||= begin
    db_exec("SELECT * FROM users WHERE SUBSTRING(options,1,1) <> 0")
  end
end #/ admins


feature "La liste des icariens" do
  before :all do
    degel('real-icare')
  end
  scenario "peut être atteinte depuis le plan du site" do
    goto("plan")
    expect(page).to have_css('a.goto[href="overview/icariens"]')
    find('a.goto[href="overview/icariens"]').click
    expect(page).to have_titre('Icariennes et icariens')
  end
  scenario 'affiche correctement les icariens actifs', only:true do
    pitch("En visitant la salle des icariens, un visiteur quelconque trouve la liste des icariens vraiment (*) actifs.(*) C'est-à-dire ceux qui possèdent un module courant et dont la dernière activité ne remonte pas à trop longtemps.")
    goto("overview/icariens")
    expect(page).to have_css("section#body h2", text: "Icariennes et icariens en activité")
    expect(icariens_actifs.count).to be > 4
    icariens_actifs.each do |dic|
      expect(page).to have_css("div.icarien#icarien-#{dic[:id]}")
      within("div#icarien-#{dic[:id]}") do
        expect(page).to have_css("span.pseudo", text: dic[:pseudo])
        expect(page).to have_css("span.date-signup", text: formate_date(dic[:created_at], jour: false).downcase)
        expect(page).to have_css("span.duree")
        expect(page).to have_css("span.module", text: "le module “#{dic[:module_name]}”")
      end
    end
  end
  scenario 'affiche correctement les anciens icariens' do
    implementer(__FILE__,__LINE__)
  end
  scenario 'propose des boutons correspondant aux préférences des icariens' do
    implementer(__FILE__,__LINE__)
  end
  scenario 'ne contient pas les administrateurs' do
    pitch("Lorsqu'il visite la salle des icariens, un visiteur quelconque ne trouve pas les administrateurs du site.")
    goto("overview/icariens")
    expect(page).to have_titre("Icariennes et icariens")
    admins.each do |admin|
      expect(page).not_to have_css("div.icarien#icarien-#{admin[:id]}")
    end
  end
end
