# encoding: UTF-8
=begin
  Pour capter les appels à log, erreur, message venant des modules chargés
  de l'application, à commencer par db.rb
=end

def log(msg, options = nil)
  # Message log capté
  # Peut-être, à l'avenir, sera-t-il intéressant de le mettre de côté ?
end #/ log
def erreur(msg, options = nil)
  # Message log capté
  # Peut-être, à l'avenir, sera-t-il intéressant de le mettre de côté ?
end #/ log
def message(msg, options = nil)
  # Message log capté
  # Peut-être, à l'avenir, sera-t-il intéressant de le mettre de côté ?
end #/ log


# Méthode pratique pour obtenir le titre (sujet) du mail de path relatif
# +mpath+.
# +mpath+ doit être un fichier ERB qui appelle une méthode 'subject' avec en
# argument le titre à donner au mail
def subject_of_mail(mpath)
  SubjectOfMail.new(mpath).return_subject
end #/ subject_of_mail

class SubjectOfMail
  attr_accessor :sujet
  def initialize(mpath)
    @mpath = mpath
  end #/ initialize
  def method_missing mname, *margs, &block
    # Pour recevoir toutes les méthodes que peut appeler le mails, sauf
    # :subject, qui seul nous intéresse ici. Mais noter que si on trouve
    # par exemple 'owner.pseudo' dans le mail, 'owner' passera ici, mais
    # la méthode :pseudo génèrera une erreur de 'Nil qui ne possède pas de
    # méthode pseudo'. Pour simplifier, on retourne donc self qui prendra
    # alors en charge la method missing. Je garde quand même le rescue
    # au cas où.
    self
  end
  def return_subject
    load
    return sujet
  end #/ return_subject
  def subject(suj)
    self.sujet = suj
  end #/ subject
  def load
    ERB.new(File.read(File.join('_lib', @mpath))).result(self.bind)
  rescue Exception => e
    # puts "ERREUR: #{e.message}"
    # Cf. l'explication de :method_missing
  end #/ load
  def bind; binding() end
end
