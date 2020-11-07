# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class TEvaluator
  ----------------
  Pour gérer les évaluateurs (membres du jury) dans les tests
=end
class TEvaluator
  include Capybara::DSL
  include SpecModuleNavigation

# ---------------------------------------------------------------------
#
#   MÉTHODES D'INSTANCE PUBLIQUES
#
# ---------------------------------------------------------------------
def rejoint_le_concours
  goto("concours/evaluation")
  within("form#concours-membre-login") do
    fill_in("member_mail", with: mail)
    fill_in("member_password", with: password)
    click_on("M’identifier")
  end
  screenshot("after-login-member-#{id}")
end

class << self
  # OUT   Un évaluateur choisi au hasard ou suivant les options +options+
  # IN    +options+ Table d'options parmi :
  #         :femme      Si true, une jurée
  #
  def get_random(options = nil)
    new(evaluators.shuffle.shuffle.shuffle.first)
  end


  # OUT   Données des évaluateurs courants
  # ALIAS def evaluators
  def data
    @data ||= begin
      require './_lib/data/secret/concours'
      CONCOURS_DATA[:evaluators]
    end
  end #/ data
  alias :evaluators :data

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :pseudo, :mail, :password, :id
def initialize(data_ini)
  @data_ini = data_ini
  @data_ini.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

def to_s
  @to_s ||= "Le membre du jury #{pseudo}"
end #/ to_s
end #/TEvaluator
