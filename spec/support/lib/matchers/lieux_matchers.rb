# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour checker les pages
=end
require_relative 'page_matchers'

RSpec::Matchers.define :be_contact_page do |options|
  match do |page|
    options ||= {}
    options[:icarien] = false unless options.key?(:icarien)
    options[:admin]   = false unless options.key?(:admin)

    @errors = []

    titre_page = options[:admin] ? 'Mailing-list' : 'Contact'
    if not page.has_css?("h2.page-title", text: titre_page)
      @errors << "devrait avoir pour titre “#{titre_page}” (son titre est #{title_of_page})"
    end
    if not page.has_css?('form#contact-form')
      @errors << 'devrait contenir le formulaire de mail'
    end
    if not page.has_css?('input[type="text"]#envoi_titre')
      @errors << "devrait avoir un champ pour entrer le titre du message"
    end
    if not page.has_css?('textarea#envoi_message')
      @errors << "devrait avoir un champ de saisie pour le texte du message"
    end
    if options[:icarien]
      # Rien de spécial pour le moment
    elsif options[:admin]
      if not page.has_css?('div#div-statuts')
        @errors << 'devrait contenir le bloc pour choisir le statut de l’icarien'
      end
      if not page.has_css?('select#message_format')
        @errors << 'devrait contenir le menu pour choisir le format du message'
      end
      if not page.has_css?('select#mail_signature')
        @errors << 'devrait contenir le menu pour choisir la signature du message'
      end
      if not page.has_button?(UI_TEXTS[:btn_apercu])
        @errors << "devrait afficher le bouton “#{UI_TEXTS[:btn_apercu]}”"
      end
    else
      if not page.has_css?('input[type="text"]#envoi_mail')
        @errors << "devrait avoir un champ pour entrer son mail"
      end
      if not page.has_css?('input[type="text"]#envoi_mail_confirmation')
        @errors << "devrait avoir un champ pour entrer la confirmation de son mail"
      end
    end



    return @errors.empty?
  end

  description do
    "C'est bien la page de contact"
  end
  failure_message do
    "Ce n'est pas la section de contact : la page #{@errors.pretty_join}"
  end

end
RSpec::Matchers.define :be_salle_icariens do
  match do |page|
    @errors = []
    if not page.has_css?("h2.page-title", text: "Icariennes et icariens")
      @errors << "ne possède pas le titre principal “Icariennes et icariens”"
    end
    [
      "Icariennes et icariens en activité",
      "Icariennes et icariens en pause",
      "Anciennes icariennes et anciens icariens",
      "Récemment reçues et reçus",
      "Candidats et candidates"
    ].each do |sous_titre|
      if not page.has_css?("h2", text:sous_titre)
        @errors << "ne possède pas le sous-titre “#{sous_titre}”"
      end
    end
    @errors.empty?
  end
  description do
    "C'est bien la salle des icariens"
  end
  failure_message do
    "Ce n'est pas la salle des icariens : la page #{@errors.pretty_join}"
  end
end
