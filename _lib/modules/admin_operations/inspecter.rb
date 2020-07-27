# encoding: UTF-8
=begin
  Outil administrateur pour marquer une page à inspecter
=end
class Admin::Operation
def inspecter(params = nil)
  laroute = param(:route)
  if db_count('validations_pages', {route: laroute}) > 0
    # La page est peut-être achevée, donc on ne la voit pas dans l'inspecteur
    dpage = db_get('validations_pages', {route:laroute})
    if dpage[:specs][31] == '1'
      db_compose_update('validations_pages', dpage[:id], {specs: '0'*32})
      msg = "La page '#{laroute}' déjà inspectée complètement a été remarquée à inspecter (#{inspector_link})."
    else
      msg = "La page '#{laroute}' est déjà marquée à inspecter (#{inspector_link})."
    end
  else
    vpage_id = db_compose_insert('validations_pages',{route:laroute, specs:'0'*32})
    msg = "La page '#{laroute}' a été marquée comme page à inspecter ##{vpage_id} (#{inspector_link})"
  end
  message(msg)
end #/ inspecter
def inspector_link
  @inspector_link ||= "<a href='admin/validator_pages'>ouvrir l’inspecteur</a>".freeze
end #/ inspector_link
end #/Admin::Operation
