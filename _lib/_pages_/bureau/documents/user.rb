# encoding: UTF-8
class User

  def nombre_documents
    @nombre_documents ||= documents.count
  end

  # def documents
  #   @documents ||= IcDocuments.new(self)
  # end

  def documents
    @documents ||= IcDocument.get_instances({user_id: id, order:'created_at DESC'})
  end #/ documents
end
