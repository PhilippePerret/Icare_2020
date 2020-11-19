# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de TMails
=end
require_relative './lib/_required'

def formate_temps(time)
  Time.at(time).strftime("%d %m %Y à %H:%M:%I")
end #/ formate_temps

describe TMails do

  def essaye(dmail)
    return expect { expect(TMails).to have_mail(dmail) }
  end #/ essaye

  let(:start_time) { @start_time }
  describe 'Le matcher has_mail' do
    before(:all) do
      @oldlen = RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length
      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 50000
      @start_time = Time.now.to_i
      # On fabrique quelques mails
      data_mails = [
        {to: "ernestine@gmail.com", subject:"Mail à Ernestine", from: "phil@atelier-icare.net", content: "Un contenu tout simple."},
      ]
      data_mails.each { |dmail| TMails.create(dmail) }

    end
    after(:all) do
      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = @oldlen
    end
    before(:each) do
    end
    it 'répond' do
      essaye(after: start_time - 10).not_to raise_error
    end
    context 'avec une recherche par destinataire' do
      it 'ne produit pas d’erreur si un mail avec le mail est trouvé' do
        essaye(to: "ernestine@gmail.com").not_to raise_error
      end
      it 'produit une erreur si aucun mail avec l’adresse n’est trouvé' do
        res = essaye(to: "albert@gmail.com")
        res.to raise_error(/Aucun mail pour albert@gmail.com ne correspond à la recherche/)
        res.to raise_error(/Aucun mail pour albert@gmail\.com n'a été trouvé/)
      end
    end #/context par destinataire
    context 'avec une recherche par expéditeur' do
      it 'ne produit pas d’erreur si un mail avec l’expéditeur a été trouvé' do
        essaye(from: "phil@atelier-icare.net").not_to raise_error
      end
      it 'produit une erreur si aucun mail avec l’expéditeur voulu' do
        res = essaye(from:"untel@gmail.com")
        res.to raise_error(/Aucun mail de untel@gmail.com ne correspond à la recherche/)
        res.to raise_error(/Aucun mail envoyé par untel@gmail.com n'a été trouvé/)
      end
    end
    context 'avec une recherche par sujet' do
      it 'ne produit pas d’erreur si un mail avec le sujet est trouvé' do
        essaye(subject: "Mail à Ernestine").not_to raise_error
      end
      it 'produit une erreur si aucun mail avec le sujet n’est trouvé' do
        res = essaye(subject: "Mail à quelqu'un d'autre")
        res.to raise_error(/Aucun mail ne correspond à la recherche/)
      end
      it 'produit une erreur avec le bon message aidant quand un destinataire est précisé et trouvé' do
        res = essaye(to: "ernestine@gmail.com", subject: "Mail à quelqu'un d'autre")
        res.to raise_error(/Aucun mail pour ernestine@gmail.com ne correspond à la recherche/)
        res.to raise_error(/Aucun mail n'a été trouvé avec le sujet “Mail à quelqu'un d'autre”/)
        res.to raise_error(/Des mails ont été trouvés avec d'autres sujets/)
        res.to raise_error(/Message du #{formate_temps(start_time)} de phil@atelier-icare.net à ernestine@gmail.com de sujet “🦋 ICARE | Mail à Ernestine”/)
      end
    end
    context 'avec une recherche par date' do
      it 'ne produit pas d’erreur avec une bonne condition :after' do
        essaye(after: start_time - 10).not_to raise_error
      end
      it 'ne produit pas d’erreur avec une bonne condition :before' do
        essaye(before: start_time + 10).not_to raise_error
      end
      it 'produit une erreur avec une mauvaise condition :after' do
        res = essaye(after: start_time + 10)
        res.to raise_error(/Aucun mail ne correspond à la recherche/)
        res.to raise_error(/Aucun mail n'a été émis après le #{formate_temps(start_time+10)}/)
      end
      it 'produit une erreur avec une mauvaise condition :before' do
        res = essaye(before: start_time - 10)
        res.to raise_error(/Aucun mail ne correspond à la recherche/)
        res.to raise_error(/Aucun mail n'a été envoyé avant le #{formate_temps(start_time - 10)}/)
      end
    end # Contexte : recherche par date



    context 'avec une recherche par contenu' do
      it 'ne produit pas d’erreur si le contenu String a été trouvé' do
        essaye(message: "Un contenu tout simple").not_to raise_error
      end
      it 'produit une erreur si le contenu String n’est pas trouvé' do
        res = essaye(message:"Pas de contenu")
        res.to raise_error(/Aucun mail ne correspond à la recherche/)
        res.to raise_error(/Aucun mail trouvé avec le contenu "Pas de contenu"/)
      end
      it 'ne produit pas d’erreur avec un contenu Array trouvé' do
        essaye(message:['contenu', 'simple']).not_to raise_error
      end
      it 'produit une erreur si un contenu Array n’est pas trouvé' do
        res = essaye(message:["n'importe","quoi"])
        res.to raise_error(/Aucun mail ne correspond à la recherche/)
        res.to raise_error(/Aucun mail trouvé avec le contenu "n'importe" et "quoi"/)
      end
    end

  end

end
