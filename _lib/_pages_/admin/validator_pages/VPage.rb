# encoding: UTF-8
=begin

  Class VPage
  -----------
  Instance de validation de la page

=end
class VPage < ContainerClass
# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------
SUBJECT_LINE  = '<span class="route"></span>'
COL_ROUTE     = '<span class="route">%{route}</span>'.freeze
SPAN_CB_TAG   = '<span class="col-cb"><input type="checkbox" value="1" name="cpage_%{id}_spec_%{bit}"%{checked} /></span>'
PICTO_BIT     = '<span class="col-cb"><img src="img/Emojis/%{picto}.png" class="picto-bit" title="%{title}" /></span>'.freeze
DIV_LINE      = '<div id="%{id}" class="vpage-line">%{cols}</div>'.freeze
OPEN_LINK     = ('<span class="col-cb"><a href="%s" target="_new">'+Emoji.get('humain/yeux-droite').texte+'</a></span>').freeze

DATA_BITS_VALIDATOR = {
  0   => {name:'Corrigé', picto:'humain/marion', title:'Marion a achevé la correction de cette page.'.freeze},
  1   => {name:'Finalisé', picto:'humain/phil', title:'Phil a corrigé les corrections de Marion'.freeze},
  2   => {name:'Sur Mac', picto:'machine/mac', title:'La page a été checkée sur les navigateurs Mac'.freeze},
  3   => {name:'Sur windows', picto:'machine/windows', title:'La page a été checkée sur les navigateurs Windows.'.freeze},
  4   => {name:'Sur tablette', picto:'machine/tablette', title:'La page a été checkée sur les tablettes (simulations)'.freeze},
  5   => {name:'Sur iPhones',  picto:'machine/iphone', title:'La page a été checkée sur l’iPhone et simulations.'.freeze},
  6   => {name:'Sur Androïde',  picto:'machine/androide', title:'La page a été checkée sur Androïde et simulations.'.freeze},

  20  => {name:'Prioritaire',   picto:'signes/exclamation', title:'Il s’agit d’une page à traiter en priorité'.freeze},
  30  => {name:'Retirer de la liste', picto:'signes/croix', title:'Pour retirer de la liste, donc détruire la page. Si elle est achevée, c’est le bouton suivant qu’il faut utiliser.'.freeze},
  31  => {name:'Achevée', picto:'signes/coched', title: 'Pour marquer la page complètement achevée (et la retirer du listing par défaut).'.freeze}
}
ORDRE_BITS = [0,1,2,3,4,5,6,20,30,31]
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'validations_pages'
  end #/ table

  # Pour enregistrer le nouvel état des pages
  #
  # Il ne faut enregistrer que les pages qui ont changé d'état
  def save
    values = []
    get_vpages(all = false).each do |vpage|
      values << [vpage.specs, vpage.id] if vpage.modified?
    end
    if values.empty?
      message(MESSAGES[:no_page_modified])
    else
      request = 'UPDATE validations_pages SET specs = ? WHERE id = ?'.freeze
      begin
        db_exec(request, values)
        message(MESSAGES[:save_success])
      rescue MyDBError => e
        erreur(e.message)
      end
    end
  end #/ save

  # Pour faire le listing des pages
  def listing
    vpages = get_vpages(all = false)
    # # Pour simuler
    # vpages = [
    #   self.instantiate({route:'home', specs:'0'*32, id:1}),
    #   self.instantiate({route:'bureau/home', specs:'0'*32, id:2}),
    #   self.instantiate({route:'overview/phil', specs:'0'*32, id:3})
    # ]
    vpages.collect do |vpage|
      vpage.out
    end.join
  end #/ listing

  def get_vpages(all = false)
    where = all ? '' : ' WHERE SUBSTRING(specs,32,1) != "1"'
    request = "SELECT id, route, specs FROM `validations_pages`#{where} ORDER BY SUBSTRING(specs,20,1) DESC".freeze
    db_exec(request).collect do |droute|
      vpage = self.instantiate(droute)
    end
  end #/ get_vpages

  # Pour faire l'entete du listing
  def listing_header
    ORDRE_BITS.each do |bit|
      SUBJECT_LINE << PICTO_BIT % DATA_BITS_VALIDATOR[bit]
    end
    SUBJECT_LINE.freeze
  end #/ listing_header
end # /<< self


# Sortie de la ligne de validation
def out
  cols = COL_ROUTE % {route: self.route}
  ORDRE_BITS.each do |bit|
    cols << (SPAN_CB_TAG % {id:id, bit:bit, checked:checked_for(bit)})
  end
  # Les boutons d'édition
  cols << (OPEN_LINK % self.route)
  DIV_LINE % {id:route, cols:cols}
end #/ out

def checked_for(bit)
  checked?(bit) ? CHECKED : EMPTY_STRING
end #/ checked_for
def checked?(bit)
  spec(bit) == 1
end #/ checked?

# Retourne TRUE si la ligne a été modifiée
def modified?
  valeurs = nil
  modified = false
  ORDRE_BITS.each do |bit|
    valeurs = []
    key = "cpage_#{id}_spec_#{bit}".to_sym
    val = param(key).to_i
    if val != spec(bit)
      data[:specs][bit] = val.to_s
      modified = true
      valeurs << "bit #{bit} = #{val}"
    end
  end
  if modified
    message("Page ##{id} modifiée : #{valeurs.join(VG)}")
  else
    message("La page ##{id} n'a pas changé")
  end
  modified
end #/ modified?

# ---------------------------------------------------------------------
#   Spécifications
#   Concerne la donnée SPECS qui est un string de 32 caractères qui
#   définit l'état de chaque chose
#   Bit       Quand 1
#   -------------------------------
#     0   Corrigée par Marion
#     1   Corrections de Marion effectuée et validée par moi
#     2   Affichage correct sur mac
#     3   Affichage correct sur Windows
#     4   Affichage correct sur une tablette
#     5   Affichage correct sur iPhones
#     6   Affichage correct sur Androïde
#
#     20  Prioritaire
# ---------------------------------------------------------------------
def corrected_by_marion
  spec(0)
end #/ corrected_by_marion?
def phil_validation
  spec(1)
end #/ phil_validation?
def aspect_mac
  spec(2)
end #/ aspect_mac?
def aspect_pc
  spec(3)
end #/ aspect_pc?
def aspect_tablette
  spec(4)
end #/ aspect_tablette
def aspect_iphones
  spec(5)
end #/ aspect_iphones
def aspect_androides
  spec(6)
end #/ aspect_androide

def priority
  spec(20)
end #/ priority
def destroyed
  spec(30)
end #/ destroy
def complete
  spec(31)
end #/ complete

def spec(bit, value = nil, save = true)
  if value.nil? # on veut obtenir la valeurs
    (specs||'0'*32)[bit].to_i
  else
    # On veut définir la valeur
    data[:specs] ||= '0'*32
    data[:specs][bit] = value.to_s
    save(:specs)
  end
end #/ spec

end #/VPage
