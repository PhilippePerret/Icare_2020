# encoding: UTF-8
require 'cgi'
require 'json'



class PiratageError < StandardError; end

class Ajax
  class << self

    def init
      Session.init
    end #/ init

    # Vérifie que la requête soit conforme et autorisée
    def checkPirate
      # La requête doit posséder un paramètre uuid
      uuid = param(:__uuid) || raise("Pas de __uuid dans la requête")
      uid  = param(:__uid)  || raise("Pas de __uid dans le requête")
      # Cet uuid doit correspondre à l'user courant
      UUID.check(uuid, uid, Session.current.id, param(:__scope)) || raise("Le check UUID est invalide")
    rescue Exception => e
      log("STOP PIRATE (#{e.message})")
      return false
    else
      return true
    end #/checkPirate

    def checkScript(script_fullpath)
      # Le script doit exister
      self << { script: param(:script) }
      return File.exists?(script_fullpath)
    end #/ checkScript

    def treate_request
      init
      log("= Script : #{param(:script)}")
      checkPirate   || raise(PiratageError.new)
      script_fullpath = File.expand_path(File.join('.','ajax','_scripts',param(:script)))
      checkScript(script_fullpath)   || raise("Le script '#{script_fullpath}' est introuvable…")

      # --- On joue le script ---
      require_relative "./_scripts/#{param(:script)}"

      # On ajoute au retour, le script joué et les clés envoyés en
      # paramètres CGI
      self << {
        # 'ran_script': script,
        'transmited_keys': cgi.params.keys.join(', '),
        'APP_FOLDER': APP_FOLDER
      }
      # Débug : pour voir ce que reçoit
      # self << {
      #   # params: cgi.params.inspect,
      #   script: script,
      #   args: args,
      #   message: message
      # }
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      STDOUT.write data.to_json+"\n"
    rescue PiratageError => e
      # STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
      # STDOUT.write "{\"Ce que j'en pense\":\"PIRATE!\"}"
      log("--- Pirate ---")
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      STDOUT.write '{"error":"Pirate", "message":"Pirate !"}'+"\n"
    rescue Exception => e
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      err = {}
      err.merge!(error: {})
      err[:error].merge!(message: e.message)
      err[:error].merge!(backtrace: e.backtrace)
      STDOUT.write err.to_json
    end #/treate_request

    # # Retourne l'argument de clé +key+
    # def arg key
    #   args[key.to_s]
    # end
    #
    # # ---------------------------------------------------------------------
    # Pour ajouter des données à renvoyer
    # Utiliser : Ajax << {ma: "data"}
    def << hashdata
      @data ||= {}
      @data.merge!(hashdata)
    end
    def data
      @data ||= {}
    end

    # Pour mettre dans le rescue des scripts (cf. manuel)
    def error e
      log("ERREUR: #{e.message}")
      log("BACTRACE ERREUR: #{e.backtrace.join(RC)}")
      self << {error: e.message, backtrace: e.backtrace}
    end

    def param key
      # v = cgi.params[key.to_s]
      # v = v[0] if v.count == 1

      # cf. mode d'emploi
      return nil if cgi.params[key.to_s].empty?
      # log("cgi.params[#{key.inspect}.to_s] = #{cgi.params[key.to_s].inspect}")
      v, typeV = JSON.parse(cgi.params[key.to_s][0])
      # log("v,typeV de #{key.inspect} = #{v.inspect}, #{typeV.inspect}")
      return case typeV
      when 'number' then v = v.to_i
      when 'boolean'  then v = v
      when 'json'     then v = JSON.parse(v)
      else v
      end
    end
    def cgi
      @cgi ||= CGI.new('html4')
    end

  end #/ << self
end
