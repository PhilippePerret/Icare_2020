<!-- corrigé -->

### Constitution du bureau

Trouvez sur cette page l'explication des différents éléments #{user.guest? ? 'd’un bureau de travail' : "de [votre bureau de travail](bureau/home)"} à l'atelier Icare.

Ce bureau est constitué des sections suivantes :

* la section du #{user.guest? ? "travail courant" : "[travail courant](bureau/travail)"} qui présente le travail de votre étape en cours si vous êtes en activité ;
* la section des #{user.guest? ? "notifications" : "[notifications](bureau/notifications)"} avec vos messages en cours ;
* la #{user.guest? ? "section des documents" : "[section des documents](bureau/documents)"} présentant le listing de tous vos documents produits à l'atelier ;
* votre #{user.guest? ? 'porte de frigo' : "[porte de frigo](bureau/frigo)"} sur laquelle vous pouvez avoir des dicussions avec Phil ou les autres icariennes et icariens ;
* votre #{user.guest? ? 'profil' : "[profil](user/profil)"} avec vos informations personnelles ;
* votre  #{user.guest? ? 'section préférences' : "[section Préférences](bureau/preferences)"} vous permettant d'effectuer vos réglages pour l'utilisation de l'atelier ;
* votre #{user.guest? ? 'historique de travail' : "[historique de travail](bureau/historique)"} qui affiche le suivi de votre travail à l'atelier, qu'il vous est possible de partager.
