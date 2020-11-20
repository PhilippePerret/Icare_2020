# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour checker les pages
=end
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
