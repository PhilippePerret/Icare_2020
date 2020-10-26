# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de la classe Linker qui permet de gérer des liens facilement
=end
require './_lib/required/__first/helpers/Linker'

describe Linker do

  context 'avec des données valides' do
    it 'permet de générer une instance de lien valide' do
      lk = Linker.new(route:'ma/route', text: 'mon texte')
      expect(lk).to be_instance_of Linker
      expect(lk).to respond_to :route
      expect(lk.route).to eq('ma/route')
      expect(lk).to respond_to :default_text
      expect(lk.default_text).to eq('mon texte')

      expect(lk).to respond_to :with
      expect(lk).to respond_to :to_str
    end
  end

  describe 'la méthode to_str' do
    it 'permet d’obtenir un lien valide avec les données par défaut' do
      lk = Linker.new(text:"mon str texte", route:"ma/route/2")
      lien = lk.to_str
      expect(lien).to eq('<a href="ma/route/2" id="" class="" title="" target="_self" style="">mon str texte</a>')
    end
  end

  describe 'la méthode with' do
    let(:linker) { @linker ||= Linker.new(text:"défaut", route:"ma/route/with") }
    context 'sans aucun argument' do
      it 'génère une erreur d’argument' do
        expect{linker.with}.to raise_error(ArgumentError)
      end
    end

    context 'avec un texte en argument' do
      it 'modifie le texte du lien' do
        lien = linker.with("autre texte")
        expect(lien).to eq('<a href="ma/route/with" id="" class="" title="" target="_self" style="">autre texte</a>')
      end
    end

    context 'avec une table en argument' do
      it 'permet de modifier plusieurs élément' do
        lien = linker.with(text: "troisième texte", target: :blank)
        expect(lien).to eq('<a href="ma/route/with" id="" class="" title="" target="_blank" style="">troisième texte</a>')
      end
    end

    context 'avec le paramètre :distant ou :online' do
      it 'retourne un lien avec une url distante complète' do
        lien = linker.with(distant: true)
        expect(lien).to eq('<a href="https://www.atelier-icare.net/ma/route/with" id="" class="" title="" target="_self" style="">défaut</a>')
        lien = linker.with(online: true, text: "adresse distante")
        expect(lien).to eq('<a href="https://www.atelier-icare.net/ma/route/with" id="" class="" title="" target="_self" style="">adresse distante</a>')
      end
    end

    context 'avec le paramètre :absolute' do
      it 'retourne un lien avec une url locale complète' do
        OFFLINE = true
        lien = linker.with(absolute: true)
        expect(lien).to eq('<a href="http://localhost/AlwaysData/Icare_2020/ma/route/with" id="" class="" title="" target="_self" style="">défaut</a>')
      end
    end

    context 'avec un query-string défini' do
      it 'l’ajoute à l’adresse' do
        lien = linker.with(query_string: "op=voir")
        expect(lien).to eq('<a href="ma/route/with?op=voir" id="" class="" title="" target="_self" style="">défaut</a>')
      end
    end

    context 'avec tous les paramètres définis' do
      it 'retourne un lien correct' do
        lien = linker.with({
          text:"grand final",
          target: :blank,
          id: 'mon-lien',
          distant: true,
          class: "ma-class-css",
          title: "un title",
          style: "font-weight:bold;",
          query_string: "op=revoir"
        })
        expect(lien).to eq('<a href="https://www.atelier-icare.net/ma/route/with?op=revoir" id="mon-lien" class="ma-class-css" title="un title" target="_blank" style="font-weight:bold;">grand final</a>')
      end
    end

    context 'en utilisant deux fois le lien' do
      it 'ne retient pas les réglages précédants' do
        lien = linker.with(distant: true)
        expect(lien).to eq('<a href="https://www.atelier-icare.net/ma/route/with" id="" class="" title="" target="_self" style="">défaut</a>')
        lien = linker.to_str
        expect(lien).to eq('<a href="ma/route/with" id="" class="" title="" target="_self" style="">défaut</a>')
      end
    end
  end


end
