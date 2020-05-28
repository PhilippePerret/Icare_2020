# encoding: UTF-8
class User

  def nombre_documents
    @nombre_documents ||= db_count('icdocuments', {user_id: user.id})
  end

  def documents
    @documents ||= IcDocuments.new(self)
  end

  def liste_documents
    documents.collect do |icdoc|
      icdoc.as_card
    end.join(RC)
  end
end
