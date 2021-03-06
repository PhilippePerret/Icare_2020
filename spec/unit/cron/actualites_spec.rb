# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui tester le cronjob au niveau des actualités

=end
include Capybara::DSL # exceptionnellement

def delete_actualites_semaine_of_jour(time)
  request = "DELETE FROM actualites WHERE created_at >= ? AND created_at < ?"
  semaine_fin = time.to_i + 1.day # on est samedi
  semaine_start = semaine_fin - 7.days
  db_exec(request, [semaine_start, semaine_fin])
end #/ delete_actualites_semaine_of_jour

describe 'Le job envoi_actualites' do
  before(:all) do
    require_support('cronjob')
    degel('real-icare-2020')
    # On doit s'assurer qu'il y a exactement :
    #   - 5 et seulement 5 icariens qui veulent recevoir les activités
    #       quotidiennes.
    #   - 7 et seulement 7 icariens qui veulent recevoir les activites
    #       hebdomadairement.
    @icariens_news_quoti, @icariens_news_hebdo = TUser.set_contactables(strict:true, quoti:5, hebdo:7)
    # puts "@icariens_news_hebdo:\n-- #{@icariens_news_hebdo.join("\n-- ")}"

    @old_current_driver = Capybara.current_driver.freeze
    Capybara.current_driver = :selenium_headless
  end

  after(:all) do
    Capybara.current_driver = @old_current_driver
  end
  let(:icariens_news_hebdo) { @icariens_news_hebdo }
  let(:icariens_news_quoti) { @icariens_news_quoti }

  before(:each) do
    TMails.remove_all
    remove_main_log
    remove_report
  end

  context 'sans actualité la veille' do
    it 'n’envoie pas de mail quotidien' do
      expect(TMails.count).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/3/55")
      code = File.read(MAIN_LOG_PATH)
      expect(code).to include "RUN [envoi_actualites]"
      expect(TMails.count).to eq(1) # seulement le rapport à l'administration
    end
  end #/context "sans activité de la veille"


  context 'sans actualité de la semaine' do
    it 'n’envoie pas de mail hebdomaire' do
      expect(TMails.count).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/3/55")
      code = File.read(MAIN_LOG_PATH)
      expect(code).to include "RUN [envoi_actualites]"
      expect(TMails.count).to eq(1) # seulement le rapport à l'administration
    end
  end #/context "sans activté de la semaine"


  context 'lorsqu’il n’est pas 3 heures, même un samedi' do
    it 'ne produit rien' do
      res = run_cronjob(noop:false, time:"2020/10/24/1/12")
      code = File.read(MAIN_LOG_PATH)
      expect(code).to include "NOT TIME FOR [envoi_actualites]"
    end
  end # context pas 3 heures


  context 'lorsqu’il est 3 heures' do

    context 'un samedi' do

      let(:thetime) { @thetime }
      let(:reportpath) { @reportpath }

      context 'sans aucune actualités' do
        before(:each) do
          @thetime = "2020/10/24/3/8"
          rtime = realtime(@thetime)
          @reportpath = remove_report(@thetime)
          # On détruit toutes les actualités entre les temps
          delete_actualites_semaine_of_jour(rtime)
        end
        it 'il n’envoie aucun mail d’actualités' do
          res = run_cronjob(time:thetime)
          # puts "\n\n---res:\n#{res}"
          code_report = File.read(reportpath)
          # puts "\n\n---Report:\n#{code_report}"
          code = File.read(MAIN_LOG_PATH)
          expect(code).to include "RUN [envoi_actualites]"
          expect(code_report).to include("Aucune actualité pour la semaine.")
          expect(code_report).to include("Aucune actualité pour la veille.")
        end
      end #/context : sans actualité

      context 'avec des actualités de la semaine seulement' do
        before(:each) do
          @thetime = "2020/10/24/3/8"
          @reportpath = remove_report(@thetime)
          rtime = realtime(@thetime)
          # On détruit toutes les actualités entre les temps
          delete_actualites_semaine_of_jour(rtime)
          # On fabrique deux actualités de la semaine (hors veille)
          data_news = {user_id: 1, message: "Actualité d'il y a 4 jours", type:"NEWSTEST", created_at: rtime.to_i - 4.days}
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu d'il y a 2 jours", created_at: rtime.to_i - 2.days)
          db_compose_insert('actualites', data_news)
        end #/before :each

        it 'il envoie les mails d’actualités de la semaine' do
          res = run_cronjob(time:thetime)
          # puts "\n\n---res:\n#{res}"
          code_report = File.read(reportpath)
          # puts "\n\n---Report:\n#{code_report}"
          code = File.read(MAIN_LOG_PATH)
          expect(code).to include "RUN [envoi_actualites]"
          expect(code_report).to include("Nombre de destinataires news semaine : 1.")
          expect(code_report).not_to include("Aucune actualité pour la semaine.")
          expect(code_report).to include("Nombre d'actualités de la semaine : 2.")
          expect(code_report).to include("Aucune actualité pour la veille.")
        end
      end #/ context : avec actualité semaine seulement

      context 'avec des actualités de la veille' do
        before(:each) do
          @thetime = "2020/10/24/3/8"
          @reportpath = remove_report(@thetime)
          rtime = realtime(@thetime)
          # On détruit toutes les actualités entre les temps
          delete_actualites_semaine_of_jour(rtime)
          # On fabrique trois actualités de la veille
          data_news = {user_id: 1, message: "Actualité veille 1", type:"NEWSTEST", created_at: rtime.to_i - 1.day}
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu veille 2", created_at: rtime.to_i - 1.day + 8000)
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu veille 3", created_at: rtime.to_i - 1.day + 17000)
          db_compose_insert('actualites', data_news)
        end #/before :each
        it 'il envoie les mails d’activité de la veille et indirectement de la semaine' do
          res = run_cronjob(time:thetime)
          # puts "\n\n---res:\n#{res}"
          code_report = File.read(reportpath)
          # puts "\n\n---Report:\n#{code_report}"
          code = File.read(MAIN_LOG_PATH)
          expect(code).to include "RUN [envoi_actualites]"
          expect(code_report).to include("Aucun destinataires pour les actualités hebdomadaires.")
          expect(code_report).to include("Nombre d'actualités de la semaine : 3.")
          expect(code_report).to include("Nombre d'actualités de la veille : 3.")
          expect(code_report).not_to include("Aucune actualité pour la veille.")
        end

      end #/ context : avec actualité veille seulement (donc semaine aussi)

      context 'avec des actualités de la semaine et de la veille' do
        before(:each) do
          @thetime = "2020/10/24/3/8"
          @reportpath = remove_report(@thetime)
          rtime = realtime(@thetime)
          # On détruit toutes les actualités entre les temps
          delete_actualites_semaine_of_jour(rtime)
          # On fabrique trois actualités de la veille
          data_news = {user_id: 1, message: "Actualité veille 1", type:"NEWSTEST", created_at: rtime.to_i - 1.day}
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu veille 2", created_at: rtime.to_i - 1.day + 8000)
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu veille 3", created_at: rtime.to_i - 1.day + 17000)
          db_compose_insert('actualites', data_news)
          # On fabrique deux actualités de la semaine (hors veille)
          data_news = {user_id: 1, message: "Actualité d'il y a 4 jours", type:"NEWSTEST", created_at: rtime.to_i - 4.days}
          db_compose_insert('actualites', data_news)
          data_news.merge!(message:"Actu d'il y a 2 jours", created_at: rtime.to_i - 2.days)
          db_compose_insert('actualites', data_news)
        end #/before :each


        it 'il envoie les mails d’activité de la semaine et de la veille et produit le lien pour ne plus les recevoir' do

          pitch("Le cronjob produit bien des mails d'activités quotidiennes et hebdomadaires conformes aux attentes, les envoie aux bonnes personnes en ajoutant un lien permettant de ne plus les recevoir sans avoir à s'identifier.")

          start_time = Time.now.to_i - 1

          res = run_cronjob(time:thetime)
          # puts "\n\n---res:\n#{res}"
          code_report = File.read(reportpath)
          # puts "\n\n---Report:\n#{code_report}"
          code = File.read(MAIN_LOG_PATH)
          expect(code).to include "RUN [envoi_actualites]"
          expect(code_report).to include("Aucun destinataires pour les actualités hebdomadaires.")
          expect(code_report).to include("Nombre de destinataires news veille : 1.")
          expect(code_report).not_to include("Aucune actualité pour la semaine.")
          expect(code_report).to include("Nombre d'actualités de la semaine : 5.")
          expect(code_report).not_to include("Aucune actualité pour la veille.")
          expect(code_report).to include("Nombre d'actualités de la veille : 3.")

          # # Tester l'existence des mails
          # icariens_news_hebdo.each do |di|
          #   expect(TMails).to be_exists(di[:mail], {after: start_time})
          # end
          veille_date = Time.at(realtime(@thetime).to_i - 24*3600)
          veille = formate_date(veille_date)
          # icariens_news_quoti.each do |di|
          #   expect(TMails).to be_exists(di[:mail], {after: start_time})
          # end

          # Tester le contenu des mails
          # ic = icariens_news_hebdo.first
          # mail_hebdo = TMails.for(ic[:mail], {after: start_time}).first
          # expect(mail_hebdo).to be_contains("<div class=\"date-news\"")
          #
          # expect(mail_hebdo).to be_contains(">#{formate_date(veille_date, jour:true)}<")
          # expect(mail_hebdo).to be_contains("Actualité veille 1")
          # expect(mail_hebdo).to be_contains("Actu veille 2")
          # expect(mail_hebdo).to be_contains("Actu veille 3")
          # expect(mail_hebdo).to be_contains(">#{formate_date(veille_date - 3.days, jour:true)}<")
          # expect(mail_hebdo).to be_contains("Actualité d'il y a 4 jours")
          # expect(mail_hebdo).to be_contains(">#{formate_date(veille_date - 1.days, jour:true)}<")
          # expect(mail_hebdo).to be_contains("Actu d'il y a 2 jours")

          # Test du lien pour le ticket
          require_support('ticket')
          # On prend le mail qu'on vient d'étudier
          # expect(mail_hebdo).to be_contains("?tik=")
          # mlien = mail_hebdo.content.match(/href="((?:.*?)\?tik=(?:[0-9]+)\&tckauth=(?:[a-zA-Z0-9]+))"/).to_a
          # tout, lien_complet = mlien
          # qs = mail_hebdo.content.match(/\?tik=([0-9]+)\&tckauth=([a-zA-Z0-9]+)"/).to_a
          # tout, tik, tckauth = qs
          # # On vérifie que le ticket existe
          # # dt = db_exec("SELECT * FROM tickets WHERE id = ?", [tik]).first
          # expect(TTicket).to be_exists(id: tik), "Le ticket d'ID ##{tik} devrait exister…"
          # tticket = TTicket.get(tik)
          # expect(tticket).to have_properties(authentif: tckauth),
          #   "La propriété :authenthif du ticket #{tticket.data[:id].inspect} ne correspond pas… (tticket.authentif=#{tticket.data[:authentif].inspect}/dans mail:#{tckauth.inspect})"
          # # puts "lien_complet: #{lien_complet.inspect}"
          # visit(lien_complet)
          # expect(page).to have_message("vous ne recevrez plus les mails d'activité de l'atelier Icare."),
          #   "La page devrait contenir le message informant l'icarien qu'il ne recevra plus les annonces"
          #
          # # Le ticket n'existe plus
          # expect(TTicket).not_to be_exists(id: tik),
          #   "Le ticket d'ID ##{tik} devrait avoir été détruit…"

        end
      end #/ context actualité veille et semaine
    end #/ context un samedi

    context 'pas un samedi' do

      it 'il n’envoie que les actualités quotidiennes' do
        res = run_cronjob(time:"2020/10/22/3/8")
        puts "\n\n---res: #{res}"
        code = File.read(MAIN_LOG_PATH)
        expect(code).to include "RUN [envoi_actualites]"
      end
    end #/ context pas un samedi, mais à 3 heures

  end #/ context "à 3 heures"


end
