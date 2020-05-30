# encoding: UTF-8
=begin
  Module qui sera chargé par toutes les sections et sous-sections
  de l'aperçu de l'atelier.
=end
class HTML
  def retour_base
    @retour_base ||= RETOUR_LINK % {route:'overview/home', titre:'Aperçu'}
  end #/ retour_base

  def tdm(current_route = nil)
    current_route ||= route.to_s
    liens = [
      {route:'overview/home'.freeze, titre: 'Description de l’atelier'.freeze},
      {route:'overview/reussites'.freeze, titre: 'Les belles réussites'.freeze},
      {route:'overview/parcours'.freeze, titre: 'Parcours fictif de 3 icarien·ne·s'.freeze},
      {route:'overview/raisons'.freeze, titre: 'Les dix bonnes raisons de choisir l’atelier Icare'.freeze}
    ].collect do |dlien|
      css = dlien[:route] == current_route ? 'current' : ''
      Tag.lien(route:dlien[:route], titre:dlien[:titre], class:css)
    end
    FloatTdm.new(liens, right:true).out
  end #/ tdm

  def lien_description
    @lien_description ||= Tag.lien(route:'overview/home', titre: 'description de l’atelier')
  end #/ lien_description

  def lien_reussites
    @lien_reussites ||= Tag.lien(route:'overview/reussites', titre: 'belles réussites')
  end #/ lien_reussites

  def lien_parcours
    @lien_parcours ||= Tag.lien(route:'overview/parcours', titre: 'Parcours de 3 icarien·ne·s')
  end #/ lien_reussites

  def lien_raisons
    @lien_raisons ||= Tag.lien(route:'overview/raisons', titre: '10 raisons de choisir l’atelier Icare')
  end #/ lien_reussites

  def lien_documents_candidature
    @lien_documents_candidature ||= Tag.lien(route:'user/signup', titre:'documents de candidature')
  end #/ lien_documents_candidature

  def lien_signup(titre = 's’inscrire')
    Tag.lien(route:'user/signup', titre: titre)
  end #/ lien_signup

  def lien_contact(titre = 'contact')
    Tag.lien(route:'contact', titre: titre)
  end #/ lien_signup

  def lien_narration
    @lien_narration ||= Tag.lien(route:'http://www.scenariopole.fr/narration', titre: 'la Collection Narration')
  end #/ lien_narration

  def lien_modules(titre = 'modules pédagogiques')
    Tag.lien(route:'modules/list', titre: titre)
  end #/ lien_modules(titre)

end #/HTML
