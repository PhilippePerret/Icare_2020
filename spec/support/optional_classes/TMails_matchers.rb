# encoding: UTF-8
# frozen_string_literal: true

# = main =
#
# Méthode principale qui permet de faire :
#   expect(TMails).to have_mail({arguments})
# ou :
#   expect(someone).to have_mail({arguments})
#
# Refactorisation de la méthode pour qu'elle offre plus de renseignements
# en cas d'échec en signalant si des messages proches ont été trouvés.
# Par exemple, lorsque le destinataire a reçu des mails, on le signale et
# on signale les divergences (mauvaise date, mauvais sujet, etc.)
RSpec::Matchers.define :have_mail do |params|

  attr_reader :positifs, :failures

  match do |owner|

    @failures = []
    @positifs = []

    # On définit exactement le destinataire
    if owner.class == TUser || (defined?(TConcurrent) && owner.class == TConcurrent) || (defined?(TEvaluator) && owner.class == TEvaluator)
      params.merge!(to: owner.mail)
    else
      params.merge!(to: params[:destinataire]) if params[:destinataire]
      params[:to] = params[:to].mail if params[:to].respond_to?(:mail)
    end

    # On définit exactement le contenu
    params.merge!(content: params.delete(:message)) if params[:message]
    params.merge!(content: params.delete(:contenu)) if params[:contenu]

    begin # pour pouvoir finir en raisant
      # On commence par ne garder que les mails du destinataire voulu s'il est
      # défini.
      if params[:to] # les mails pour…
        @destinataire = params[:to] # pour les messages
        candidats = TMails.all.select do |mail|
          mail.destinataire == params[:to]
        end
        msg_success = if candidats.count == 1
                        "1 mail pour #{params[:to]} a été trouvé"
                      elsif candidats.count > 1
                        "#{candidats.count} mails pour #{params[:to]} ont été trouvés"
                      else
                        ""
                      end
        btest(
          candidats.count > 0,
          msg_success,
          "Aucun mail pour #{params[:to]} n'a été trouvé",
          fatale = true
        )
      else
        candidats = TMails.all.dup
        if candidats.count == 0
          @failures << "Aucun mail n'a été envoyé."
          raise
        end
      end

      if params[:from] # les mails de…
        @expediteur = params[:from] # pour les messages
        candidats = candidats.select do |mail|
          mail.expediteur == params[:from]
        end
        # ---
        if candidats.count > 0
          msg_success = if candidats.count == 1
                          "1 mail de #{params[:from]} a été trouvé"
                        elsif candidats.count > 1
                          "#{candidats.count} mails de #{params[:from]} ont été trouvés"
                        end
          # On ajoute ça aux messages positifs
          @positifs << msg_success
        else
          @failures << "Aucun mail envoyé par #{params[:from]} n'a été trouvé"
          raise
        end
      end

      # Pour savoir les conditions testées en cas d'échec
      conditions_tested = []

      # Ci-dessus, le tests aurait raisé en cas d'erreur, dont il y a forcément
      # des mails candidats La suite va devoir produire des messages qui doivent
      # ressembler à "ne contient pas le sujet “bla bla bla” mais contient le
      # sujet “bla bla bla”"
      candidats_all = candidats.dup # pour tester sur toute la liste chaque fois
      if params[:after]
        params[:after] = params[:after].to_i if not(params[:after].is_a?(Integer))
        params.merge!(date_after: Time.at(params[:after]).strftime("%d %m %Y à %H:%M:%I"))
        exclus = []
        candidats = candidats_all.select do |mail|
          mail.timestamp >= params[:after] ? true : (exclus << mail ; false)
        end
        if candidats.count > 0
          msg_success = if candidats.count == 1
                          "1 mail a été envoyé après #{params[:date_after]}"
                        elsif candidats.count > 0
                          "#{candidats.count} mails ont été envoyés après #{params[:date_after]}"
                        end
          # ---
          @positifs << msg_success
        else # erreur
          @failures << "Aucun mail n'a été émis après le #{params[:date_after]}"
        end
        conditions_tested << :after
      end

      if params[:before]
        params[:before] = params[:before].to_i if not(params[:before].is_a?(Integer))
        params.merge!(date_before: Time.at(params[:before]).strftime("%d %m %Y à %H:%M:%I"))
        # Principe de recherche de ce second temps :
        # On cherche des mails envoyés avant le temps donné dans les candidats
        # retenus à l'étape précédente (:after). Si on en trouve, tout va bien
        # dans le cas contraire, on cherche dans la liste complète des candidats
        # ceux qui pourraient correspondre.
        exclus = []
        candidats = candidats.select { |mail| mail.timestamp <= params[:before] }
        if candidats.count > 0
          if candidats.count == 1
            @positifs << "1 mail a été envoyé avant #{params[:date_before]}"
          else
            @positifs << "#{candidats.count} mails ont été envoyés avant #{params[:date_before]}"
          end
        else
          exclus = candidats_all.select { |mail| mail.timestamp <= params[:before] }
          if exclus.count > 0 # des exclus trouvés
            raisons = test_raisons_in_exclus(exclus, params, conditions_tested)
            if exclus.count == 1
              @positifs << "1 mail a été envoyé avant, mais qui ne respecte pas les conditions précédentes :#{raisons}"
            else
              @positifs << "#{exclus.count} mails ont été envoyés avant, mais qui ne respectent pas les conditions précédentes :#{raisons}"
            end
          else
            @failures << "Aucun mail n'a été envoyé avant le #{params[:date_before]}"
          end
        end
        conditions_tested << :before
      end

      if params[:subject]
        exclus = []
        candidats = candidats.select { |mail| mail.subject.include?(params[:subject]) }
        if candidats.count > 0
          if candidats.count == 1
            @positifs << "1 mail a été trouvé avec le sujet “#{params[:subject]}”"
          else
            @positifs << "#{candidats.count} mail/s ont/a été trouvé/s avec le sujet “#{params[:subject]}”"
          end
        else # pas de mail avec ce sujet, il faut chercher dans la liste complète
          # On cherche les sujets qu'ont eu les candidats retenus
          sujets_trouves = candidats_all.collect { |mail| mail.ref }
          @positifs << "Des mails ont été trouvés avec d'autres sujets :\n\t\t* #{sujets_trouves.join("\n\t* ")}"
          # On cherche si le sujet a été trouvé ailleurs
          exclus = candidats_all.select { |mail| mail.subject.include?(params[:subject]) }
          if exclus.count > 0
            raisons = test_raisons_in_exclus(exclus, params, conditions_tested)
            if exclus.count == 1
              @positifs << "1 mail a été envoyé avec le bon sujet, mais qui ne respecte pas les conditions précédentes :#{raisons})"
            else
              @positifs << "#{exclus.count} mails ont été envoyés avec le bon sujet, mais qui ne respectent pas les conditions précédentes :#{raisons})"
            end
          else
            @failures << "Aucun mail n'a été trouvé avec le sujet “#{params[:subject]}”"
          end
        end

        conditions_tested << :subject
      end

      if params[:content]
        params[:content] = [params[:content]] if not(params[:content].is_a?(Array))
        candidats = candidats.select do |mail|
          if mail.contains?(params[:content])
            true
          else
            @failures << "#{mail.ref} ne contient pas #{mail.ne_contient_pas.pretty_join}"
            false
          end
        end

        if candidats.count > 0
          if candidats.count == 1
            @positifs << "1 mail a été trouvé avec le contenu #{params[:content].pretty_join}"
          else
            @positifs << "#{candidats.count} mails ont été trouvés avec le contenu #{params[:content].pretty_join}"
          end
        else
          @failures << "Aucun mail trouvé avec le contenu #{params[:content].pretty_join}"
          # Aucun mail trouvé avec ce contenu
          # Pour le moment, on ne cherche pas plus que ça
          # exclus = []
        end
        conditions_tested << :content
      end

    rescue Exception => e
      # puts "#{e.message}"
      return false
    else
      return candidats.count > 0 # ok
    end
  end

  def test_raisons_in_exclus(exclus, params, conditions_tested)
    raisons = []
    exclus.each do |mail|
      conditions_tested.each do |key|
        case key
        when :after
          mail.timestamp >= params[:after] || raison << "#{mail.ref} envoyé avant #{params[:date_after]}"
        when :before
          mail.timestamp <= params[:before] || raison << "#{mail.ref} envoyé après #{params[:date_before]}"
        when :subject
          mail.subject.include?(params[:subject]) || raison << "#{mail.ref} ne contient pas le sujet “#{params[:subject]}” (son sujet est “#{mail.subject}”)"
        end
      end
    end
    return "\n\t\t* (#{raisons.join("\n\t\t* ")}"
  end #/ test_raisons_in_exclus

  # "btest" pour "build test", pour construire le message d'erreur finale
  # +condition+     {Bool} Si false, c'est une erreur à comptabiliser
  # +pos_message+   {String} Le message de succès à garder en cas de succès
  # +err_message+   {String} le message d'erreur à mémoriser
  # +fatale+        {Bool} Si true et que condition est false, on raise pour
  #                 terminer.
  def btest(condition, pos_message, err_message, fatale = false)
    if condition
      @positifs << pos_message
    else
      @failures << err_message
    end
    raise if fatale and not(condition)
  end #/ btest

  description do
    "Un ou plusieurs messages ont bien été envoyés avec les paramètres requis"
  end

  failure_message do
    intro = "Aucun mail"
    intro = "#{intro} de #{@expediteur}" unless @expediteur.nil?
    intro = "#{intro} pour #{@destinataire}" unless @destinataire.nil?
    intro = "#{intro} ne correspond à la recherche."
    @positifs = positifs.compact
    @failures = failures.compact
    segs = [intro]
    segs << "\nDétail des points positifs :\n\t* #{positifs.join("\n\t* ")}" if not(positifs.empty?)
    segs << "\nRaison(s) :\n\t* #{failures.join("\n\t* ")}" if not(failures.empty?)
    "\n\n#{segs.join(" ")}\n\n"
  end
end
