### Introduction

Cette page présente la politique de confidentialité des données appliquée par l’atelier Icare.

### Informations personnelles

Lors de votre inscription, l’atelier ne récolte que les informations utiles au travail au sein de l’atelier et à la navigation sur le site.

* Le **pseudo** est utilisé au sein de l’atelier pour identifier l’icarienne ou l’icarien, dans les documents, dans les actualités, etc. L’icarien ou l’icarienne est libre de le changer par simple demande.
* Le **patronyme** — nom et prénom — est une information optionnelle. Il permet notamment d’identifier l’icarienne ou l’icarien sous son vrai nom, s’il ou elle le désire, dans le #{StringHelper.hall_of_fame}.
* Le **mail** est indispensable pour toute la communication entre l’icarien, Phil et l’administration. Ce mail ne sera cependant jamais divulgué ni utilisé à d’autres fins que celle du travail au sein de l’atelier Icare.
* Le **sexe** est indispensable pour permettre l’affichage de messages “inclusifs” personnalisés et sexués sur les pages du site de l’atelier.
* l’**âge** est une donnée importante qui permet à Phil d’estimer la maturité de l’auteure ou de l’auteur. On ne peut pas appliquer la même exigence à une jeune adulte de dix-sept ans qui n’a jamais écrit qu’à un homme mûr qui pratique l’écriture depuis 20 ans.
* L’**identifiant de session**. C’est un nombre aléatoire produit par le navigateur à chaque ouverture. Il est conservé en mémoire le temps d’une connexion et permet de maintenir le fil entre les différentes pages. C’est lui qui permet, notamment, de rester identifié de page en page.
* La **date d’inscription** est conservée à des fins informatives et statistiques uniquement dans le cadre de l’atelier Icare.
* Le **mot de passe** est conservé de façon cryptée dans la base de données, rendant impossible toute utilisation frauduleuse par un tiers.

#### Suivi de l'adresse IP

L’adresse IP de l’utilisateur est conservé de façon tout à fait anonyme — même lorsque l’icarien·ne est connecté·e — dans un fichier journal qui n’a pour but que le bon fonctionnement du site de l’atelier et le bon affichage des pages.

#### Modification des informations personnelles

À tout moment l’icarienne ou l'icarien a la possibilité, sur la page de #{user.guest? ? "son profil" : profil("son profil")}, de modifier ces informations ou d'obtenir un nouveau mot de passe.

#### Durée de vie des informations personnelles

Lorsque l’on est icarien·ne, c’est pour la vie. L’icarien·ne peut profiter *ad eternam* des services de l’atelier, conserver son bureau intact, revoir son travail, consulter les documents du [Quai des docs](qdd/home), les nouveaux comme les anciens, etc.

Pour ce faire, ses informations personnelles sont conservées *ad eternam* elles aussi. Tout icarien et toute icarienne a cependant la possibilité de détruire à tout moment son profil, sans requête, par simple confirmation sur sa #{user.guest? ? "page de profil" : profil("page de profil")}.

### Modules suivis

L'atelier Icare garde une trace, à vie, des modules suivis par l'icarien ou l'icarienne ainsi que toutes les étapes suivies. Ces informations comprennent :

* La nature du module (son nom), sa date de démarrage et de fin ou d'abandon,
* les étapes propres qui ont été réalisées, leur date de début et de fin,
* l'information des documents associés à ces étapes, avec leur date de remise et la date de remise des commentaires.

En aucun cas ces informations ne pourront être transmises à un tiers, quel qu'il soit.

L'icarien ou l'icarien pourra toujours trouver cette information dans la #{user.guest? ? "section Historique" : Tag.lien(route:"bureau/historique", text:"section Historique")} de son bureau.

À la destruction complète de son profil, ces informations deviennent anonyme et ne sont conservées qu'à titre statistique à l'usage exclusif de l'atelier.

### Partage des documents

Le #{StringHelper.quai_des_docs} est une ressource unique de l’atelier, qui joue un rôle intense et durable dans la pédagogie pratiquée et la vie de l’atelier. Il permet la consultation des milliers de documents produits au cours de la vie déjà longue de l’atelier (#{Time.now.year - 2008} ans aujourd’hui #{formate_date}).

Bien sûr, chaque auteure et chaque auteur reste propriétaire à vie de son travail et il ou elle décide de le partager ou non. Un formulaire permet de décider du partage à appliquer à chaque document, original et commenté, dans la #{user.guest? ? "section documents" : Tag.lien(route:"bureau/documents", text:"section documents")} du bureau.

Lorsque l’icarien ou l’icarienne quitte l’atelier — pour peu qu’il le quitte vraiment — ses documents restent consultables, pour une durée indéterminée. Il peut bien entendu faire la demande expresse de leur suppression, mais ce serait alors contraire à la philosophie de partage appliquée à l’atelier Icare, philosophie dont l’auteure ou l’auteur a certainement profité tout au long de son apprentissage en consultant les travaux des autres icariens et icariennes…

#### Cotes des documents

Des cotes — notes de 1 à 5 — peuvent être attribuées par les lecteurs — les autres icariens et icariennes — aux documents partagés sur le Quai des docs. Ces cotes permettent d’établir un classement subjectif des documents, par pertinence.

Ces cotes sont nominatives — l’identifiant de l’icarien-lecteur ou de l’icarienne-lectrice est consigné avec sa cote — mais cette information reste à l’usage strict de l’administration du site. L’icarien ou l’icarienne, même lorsqu’il ou elle est l’auteur ou l’auteure du document visé, ne peut avoir accès à cette information. Les cotes, par nature, restent donc strictement anonymes.

De même que les documents, ces cotes sont conservées à vie, même lorsque l’icarienne ou l’icarien quitte l’atelier définitivement — c’est-à-dire lorsqu’il détruit son inscription. Dans ce dernier cas, ses cotes deviennent anonymes, l’identifiant n’est plus associé à la cote.

### Informations professionnelles

Dans sa section #{MainLink[:reussites].simple}, l'atelier présente au jour le jour les réussites professionnelles des icarien·ne·s qui ont profité de l'apprentissage de l'atelier. Cet affichage se fait toujours avec l'accord implicite de l'icarien·ne lorsque c'est lui ou elle qui a communiqué l'information à l'administration de l'atelier ou Phil, ou par demande explicite lorsque cette information a été trouvée par l'administration de l'atelier.

Lorsque l'information existe, c'est le patronyme qui est utilisé pour l'annonce.

Quelle que soit la situation, l'icarien·ne a la possibilité, sur simple demande non argumentée, de supprimer l'information le ou la concernant, ou de la rendre *anonyme* en utilisant son pseudonyme plutôt que son patronyme.

### Politique en matière de communication

C'est l'icarien ou l'icarienne qui détermine la nature et la fréquence de la communication qui peut lui être faite. Par défaut, l'icarien ou l'icarienne reçoit une information quotidienne sur l'avancée des travaux de ses condisciples, mais seulement s'il y a eu avancée. Dans les faits et une activité normale de l'atelier Icare, cette information peu intrusive correspond à deux ou trois mails par semaine (pour la rendre plus utile encore, elle est accompagnée d'une citation propre à l'écriture qui peut servir de source de méditation).

L'icarien·ne détermine également la nature de la communication avec le reste du monde, c'est-à-dire les autres icarien·ne·s ou les simples visiteurs. Pour chacun, l'icarien·ne peut accepter ou refuser d'être contacté·e par mail ou par “message de frigo”, une messagerie interne propre à l'atelier. Par défaut, l'administration seule — Phil inclus — peut contacter l'icarien ou l'icarienne par mail. Par défaut encore, seule l'administration et les autres icarien·ne·s peuvent établir un contact par la “porte du frigo”. Les simples visiteurs n'ont aucun moyen de contacter l'icarienne ou l'icarien sans son autorisation explicite.

Même lorsque le contact par mail est accepté, l'adresse mail de l'icarien·ne demeure cachée, le message du mail étant envoyé de façon transparente depuis le site, par la [section “Contact”](contact/mail).

L'apprenti·e-auteur·e peut définir ou modifier à tout moment toutes ces informations dans la #{user.guest? ? "section Préférences" : section_preferences} de son bureau.

À noter qu'au sein de l'atelier Icare, cette communication est exclusivement *informative*. L'atelier revendiquant le fait de ne pas être une “épicerie”, il ne sera jamais émis de messages de promotion ou d'avantages de quelconque nature.

### Conservation du mail d'un visiteur quelconque

Les visiteurs quelconque ont la possibilité, lorsque l’icarien·ne l’autorise, de déposer [un message sur le frigo](aide/fiche?aid=50) d’un·e apprenti·e auteur·e. Pour ce faire, le visiteur doit laisser son adresse email afin de pouvoir être contacté par l’icarien·ne. Cette adresse n’est ni conservée ni transmise à un tiers, sous aucun prétexte. Elle est détruite sitôt que l’icarien·ne a répondu au-dit message ou l’a détruit.

### Mini-FAQ

L'atelier met à la disposition de l'icarien·ne et de l'utilisateur quelconque deux mini Foires Aux Questions qui permettent de poser des questions et d'en obtenir les réponses. Ces réponses sont ensuite accessibles à tout autre visiteur (sauf pour les questions concernant les étapes de travail). L'identifiant de l'icarien·ne est conservé avec la question qu'il a posée. Ici aussi, la destruction du profil entraine l'anonymatisation de la question.

Pour les questions concernant les modules d'apprentissage (#{StringHelper.section_modules}), il est demandé à l'utilisateur de fournir son adresse mail s'il veut être averti de la réponse faite à sa question. Cette adresse mail est conservée de façon provisoire et sera définitivement détruite, sans autre utilisation, dès l'avertissement envoyé par mail. L'utilisateur a également la possibilité de ne pas la soumettre, dans lequel cas il devra revisiter le site plus tard pour trouver une réponse à sa question.


### Durée de vie des autres informations

Conformément à la loi, les factures ne sont conservées que pendant une durée de 6 ans.
