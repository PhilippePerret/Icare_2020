# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour tester la liste des icariens
=end
require_relative './_required'

# Méthode qui va dispatcher les différents icariens dans des listes pour
# vérifier qu'ils soient affichés au bon endroit et de la bonne manière
def dispatch_icariens
  @listes_icariens = {}
  # On commence par relever la date de dernière activité des icariens (qu'on
  # placera dans leur Hash de données)
  hlast_activites = get_date_last_activites

  @module_project_names = get_module_project_names

  db_exec("SELECT * FROM users").each do |du|
    du.merge!(last_activity_at: hlast_activites[du[:id]]) # peut être nil
    opts = du[:options]
    bitstatus = opts[16].to_i
    if opts[0].to_i > 0
      statut = :admin
    elsif opts[3].to_i == 1
      statut = :detruit
    else
      statut =  case bitstatus
                when 2 then real_statut_of_actif(du)
                when 3 then :candidat
                when 4 then :inactif
                when 6 then :recu
                when 8 then :en_pause
                else :icarien # au cas où
                end
    end
    @listes_icariens.key?(statut) || @listes_icariens.merge!(statut => [])
    @listes_icariens[statut] << du
  end
end #/ dispatch_icariens

# Un icarien actif peut être un "vrai" actif ou un "faux" actif suivant
# que sont dernier document ait été actualisés moins de 6 mois avant
# aujourd'hui.
ILYA_SIX_MOIS = Time.now.to_i - 6*4.weeks
def real_statut_of_actif(du)
  if du[:last_activity_at].nil?
    # Cas d'un icarien qui viendrait de commencer son module et n'aurait pas
    # encore produit de document
    :vrai_actif
  elsif du[:last_activity_at] > ILYA_SIX_MOIS
    :vrai_actif
  else
    :faux_actif
  end
end #/ real_statut_of_actif

def vrais_actifs  ; @listes_icariens[:vrai_actif]   end
def faux_actifs   ; @listes_icariens[:faux_actif]   end
def inactifs      ; @listes_icariens[:inactif]      end
def candidats     ; @listes_icariens[:candidat]     end
def en_pauses     ; @listes_icariens[:en_pause]     end
def recus         ; @listes_icariens[:recu]         end
def detruits      ; @listes_icariens[:detruit]      end
def admins        ; @listes_icariens[:admin]        end


feature "La SALLE DES ICARIENS" do
  before :all do
    degel('real-icare')
    dispatch_icariens
  end
  scenario "peut être atteinte depuis le plan du site" do
    goto("plan")
    expect(page).to have_css('a.goto[href="overview/icariens"]')
    find('a.goto[href="overview/icariens"]').click
    expect(page).to have_titre('Icariennes et icariens')
  end

  scenario 'peut être atteinte à l’aide de la route raccourcie :icariens' do
    goto("icariens")
    expect(page).to be_salle_icariens
  end

  scenario 'n’affiche pas les administrateurs' do
    goto("icariens")
    expect(page).to be_salle_icariens
    admins.each do |di| # di = Data Icarien
      expect(page).not_to have_css("div.icarien#icarien-#{di[:id]}")
    end
  end

  scenario 'n’affiche pas la liste des icariens détruits' do
    goto("icariens")
    expect(page).to be_salle_icariens
    unless detruits.nil?
      detruits.each do |di|
        expect(page).not_to have_css("div.icarien#icarien-#{di[:id]}")
      end
    end
  end

  scenario 'affiche correctement les icariens actifs' do
    pitch("En visitant la salle des icariens, un visiteur quelconque trouve la liste des icariens vraiment (*) actifs.(*) C'est-à-dire ceux qui possèdent un module courant et dont la dernière activité ne remonte pas à plus de 6 mois.")
    goto("overview/icariens")
    expect(page).to have_css("section#body h2", text: "Icariennes et icariens en activité")
    unless vrais_actifs.nil?
      expect(vrais_actifs.count).to be > 4
      vrais_actifs.each do |di|
        expect(page).to have_css("div.icarien.actif#icarien-#{di[:id]}")
        within("div#icarien-#{di[:id]}") do
          expect(page).to have_css("span.pseudo", text: di[:pseudo])
          expect(page).to have_css("span.date-signup", text: formate_date(di[:created_at], jour: false).downcase)
          expect(page).to have_css("span.duree")
          # project_name = @module_project_names[di[:icmodule_id]]
          # module_name = @absmodule_names[di[:icmodule_id]]
          # expect(page).to have_css("span.module", text: "le module “#{di[:module_name]}”")
        end
      end
    end
  end

  scenario 'affiche correctement les anciens icariens (inactifs)' do
    goto("icariens")
    expect(page).to be_salle_icariens
    unless inactifs.nil?
      inactifs.each do |di|
        # if not page.has_css?("div.icarien.inactif#icarien-#{di[:id]}")
        #   puts "di erroné : #{di.inspect}"
        # else
          expect(page).to have_css("div.icarien.inactif#icarien-#{di[:id]}")
        # end
      end
    end
  end

  scenario 'affiche correctement les icariens en pause' do
    unless en_pauses.nil?
      goto("icariens")
      expect(page).to be_salle_icariens
      en_pauses.each do |di|
        expect(page).to have_css("div.icarien.en-pause#icarien-#{di[:id]}")
      end
    end
  end

  scenario 'affiche correctement les icariens candidats' do
    if candidats.nil?
      puts "Aucun candidat, impossible de tester leur affichage"
    else
      goto("icariens")
      expect(page).to be_salle_icariens
      candidats.each do |di|
        expect(page).to have_css("div.icarien.candidat#icarien-#{di[:id]}")
      end
    end
  end

  scenario 'affiche correctement les icariens reçus' do
    if recus.nil?
      puts "Aucun reçu, impossible de tester leur affichage".rouge
    else
      goto("icariens")
      expect(page).to be_salle_icariens
      recus.each do |di|
        expect(page).to have_css("div.icarien.recu#icarien-#{di[:id]}")
      end
    end
  end


  scenario 'propose des boutons correspondant aux préférences des icariens' do
    # implementer(__FILE__,__LINE__)
    # TODO
  end


end

def get_date_last_activites
  h = {}
  request = "SELECT user_id, max(updated_at) AS at FROM icdocuments GROUP BY user_id"
  db_exec(request).each do |d|
    h.merge!(d[:user_id] => d[:at].to_i)
  end
  return h
end #/ get_date_last_activites

# Retourne les titres des projets par ID de module, s'ils existent
def get_module_project_names
  hnames = {}
  request = "SELECT id, project_name FROM icmodules WHERE project_name IS NOT NULL"
  db_exec(request).each do |d|
    hnames.merge!(d[:id] => d[:project_name])
  end
  return hnames
end #/ get_module_project_names
