# encoding: UTF-8
=begin
  Constantes pour le Quai des docs
=end


MESSAGES.merge!({
  # Le message d'avertissement à placer au-dessus de toute liste de
  # documents et également dans un fichier "AVERTISSEMENT.txt" dans
  # les dossiers de téléchargement
  warning_copyright: "Veuillez noter, %{pseudo}, que ces documents sont <b>strictement réservés à votre usage personnel</b> au sein de l'atelier Icare et ne doivent EN AUCUN CAS — sauf autorisation expresse de leurs auteures ou auteurs — être transmis à un tiers ou utilisés à vos propres fins. Merci d’avance pour les auteures et auteurs qui, comme vous, ont produit ce travail relevant de la propriété intellectuelle.".freeze,
  warning_user_essai: "En tant qu’icarien%{ne} à l’essai, vous n’êtes en mesure de charger que <b>5 documents</b> du Quai des docs. Vous êtes actuellement à %{nb} document%{s} téléchargé%{s}, il vous en reste donc <strong>%{reste}</strong> à télécharger.".freeze,
  no_document_with_params: "Aucun document trouvé avec les paramètres choisis.".freeze,
})
