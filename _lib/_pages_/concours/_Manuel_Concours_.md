# Concours<br>Manuel d'utilisation

## Tables SQL

### Table « concours »

Table pour un concours donné. Sa propriété `annee` conserve l’année du concours.

`phase` détermine la phase courante du concours.

### Table « concours_concurrents »

Table consignant tous les concurrents aux concours (précédents, présents et futurs), icariens ou non.

### Table « concurrents_per_concours »

Table qui lie un concurrent et un concours, par les propriétés `annee` (pour le concours) et `concurrent_id` pour le concurrent.

---

# Phases du concours

La phase courante du concours détermine là où on se trouve du concours. Elle est maintenue par la propriété `phase` dans la base de données

| phase | Description                |          | Note                                                                                                                                                                                                                                                                                                                     |
| ----- | -------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 0     | Concours en attente        | *état*   | Le concours est en attente, rien n’est affiché.<br />Un visiteur quelconque peut s’inscrire (notamment pour être averti)                                                                                                                                                                                                 |
|       |                            | *action* | Déterminer le prochain thème.<br />Composer le jury.                                                                                                                                                                                                                                                                     |
|       |                            | *pivot*  | Le concours est lancé                                                                                                                                                                                                                                                                                                    |
| 1     | Le concours est en cours   | *état*   | Un visiteur peut s’inscrire, un visiteur peut transmettre son synopsis.<br />Un évaluateur peut commencer à lire le synopsis et l’évaluer.<br />Le concours est annoncé sur l’atelier.<br />Le thème est déterminé, le concurrent peut commencer à écrire.                                                               |
|       |                            | *action* | Les concurrents sont avertis du lancement du concours.                                                                                                                                                                                                                                                                   |
|       |                            | *pivot*  | Arrivée à échéance/fin du dépôt possible                                                                                                                                                                                                                                                                                 |
| 2     | Échéance                   | *état*   | Un visiteur peut toujours s’inscrire, mais pour la session suivante (avertissement).<br />Un concurrent ne peut plus transmettre de document.<br />Un évaluateur peut toujours lire et évaluer le synopsis.<br />L’administrateur ne peut pas produire les fiches de lecture (officiellement) ni afficher les résultats. |
|       |                            | *action* | Un mail est envoyé aux concurrents pour annoncer la fin de l’échéance et décrire un peu la suite (sélection).                                                                                                                                                                                                            |
|       |                            | *pivot*  | Les dix scénarios de la première sélection ont été choisis.                                                                                                                                                                                                                                                              |
| 3     | Première sélection         | *état*   | Les synopsis sont sélectionnés pour la sélection finale.<br />Un mail annonce aux perdants qu’ils n’ont pas été retenus.<br />Un mail annonce aux gagnants du premier tour qu’ils ont été retenus.                                                                                                                       |
|       |                            | *action* | Mail envoyé aux concurrents pour annonce de la première sélection                                                                                                                                                                                                                                                        |
|       |                            | *pivot*  | Les 3 synopsis lauréats ont été choisis                                                                                                                                                                                                                                                                                  |
| 5     | Palmarès                   | *état*   | L’administrateur peut afficher les résultats, produire les fiches de lectures, informer les concurrents des résultats.<br />Les concurrents peuvent consulter leurs résultats sur leur espace.<br />Un visiteur quelconque peut toujours s’inscrire, mais pour la session suivante (avertissement).                      |
|       |                            | *action* | Mail d’annonce des résultats aux concurrents                                                                                                                                                                                                                                                                             |
|       |                            | *pivot*  | Fin officielle du concours                                                                                                                                                                                                                                                                                               |
| 8     | Fin officielle du concours | *état*   | Le concours n’est plus annoncé sur l’atelier.                                                                                                                                                                                                                                                                            |
|       |                            | *action* | Mail de fin de concours, remerciements aux concurrents, annonce de la prochaine session.<br />Remerciements aux membres du jury.                                                                                                                                                                                         |
| 9     | Concours nettoyé           | *état*   | Les éléments du concours sont nettoyés pour permettre le lancement et le traitement du prochain concours.                                                                                                                                                                                                                |

---

### Phase 0

C’est la phase où le concours de telle année (l’année suivante) n’est pas encore lancé. Les visiteurs trouvent un encart sur la page d’accueil qui leur annonce cet état et permet aux non inscrits de s’inscrire avant l’heure.

### Phase 1

C’est la phase qui commence quand le concours est lancé et se termine à l’échéance du dépôt de tous les synopsis. N’importe quel participant peut s’inscrire et déposer son dossier de candidature. Il peut définir ses préférences, par exemple déterminer s’il veut recevoir un mail de rappel ou non.

### Phase 2

C’est la phase qui débute à l’échéance des dépôts et se termine lorsque les 10 dossiers de la présélection ont été choisis par le premier jury. Dans cette phase, le premier jury doit choisir 10 dossiers qui concourront pour les trois prix finaux.

### Phase 3

Phase qui commence à la sélection des 10 dossiers finaux et s’achève lorsque le palmarès a été déterminé et que les trois prix ont été décernés (ou pas).

### Phase 5

Phase qui commence à l’annonce du palmarès et s’achève lorsque l’administrateur détermine que le concours est fini. Pendant cette phase, les concurrents (et le monde) peut consulter le palmarès et lire les synopsis des trois lauréats. Les concurrents peuvent récupérer leur fiche de lecture détaillée.

### Phase 8

Phase qui commence lorsque l’administrateur définit la fin du concours de cette session. Environ 1 mois après l’annonce des résultats ? Elle se termine lorsque le « nettoyage » de cette session est terminé.

### Phase 9

Le nettoyage de la session du concours est terminé, il est officiellement et définitivement terminé. Tous les dossiers doivent avoir été « compilés » pour tenir moins de place.

---

### Opérations pour chaque phase

On peut définir les opérations et les informations à donner à chaque passage d’étape dans le fichier [phases_data](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/_pages_/concours/admin/lib/phases_data.rb). On trouve par exemple :

```ruby
STEPS_DATA = {
  ...
  5 => {name:"Le nom commun", name_current:"Nom quand étape courante", name_done:"Nom quand achevée"
    operations: [
        {name:"Nom de l'opération qui doit jouer la méthode :method", method: :ma_methode_de_cinq}, # (1)
      {name:"Nom de l'information à afficher", info: true}, # (2)
    ]
    }
  }
```

(1) Pour définir une méthode à jouer lorsque l'on passe à cette étape. Cette méthode doit être définie (avec argument `options`) dans le fichier `concours/xmodules/admin/operations/phase_operations/phase_X.rb` ([phase_5.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/_pages_/concours/xmodules/admin/operations/phase_operations/phase_5.rb) pour l’étape 5).

(2) Pour définir une ligne informative qui donnera juste une information, par exemple en disant ce que ce passage à l’étape va entrainer comme changement sur l’espace personnel des concurrents, sur la page d’accueil, etc.

---

## Les concurrents

### Options

| bit | Description                                         | Valeurs            |
| --- | --------------------------------------------------- | ------------------ |
| 0   | Réception des informations régulières par mail      | 0: non, 1: oui     |
| 1   | Réception de la fiche de lecture en fin de concours | 0: non, 1: oui     |
| 2   | Le concurrent est-il un icarien ?                   | 0: non, 1: icarien |
| 3   |                                                     |                    |
| 4   |                                                     |                    |

---

## Les fichiers de candidature

On peut évaluer les fichiers de candidature dans la section `concours/administration`.

La propriété `specs` de la donnée du concurrent dans la table `concurrents_per_concours` permet de tenir à jour les informations et l’état du fichier de candidature :

| bit | Description                                                                                                    | Valeurs                                      |
| --- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| 0   | État de dépôt du fichier<br />Répond à `<concurrent>.dossier_transmis?`                                        | 0: non déposé, 1: déposé                     |
| 1   | Conformité du fichier (après vérification par l'administration)<br />Répond à `<concurrent>.fichier_conforme?` | 0: non vérifié, 1: conforme, 2: non conforme |
| 2   | Présélectionné ?<br />Répond à `<concurrent>.preselected?`                                                     | 0: non, 1: oui                               |
| 3   | Lauréat<br />Répond à `<concurrent>.prix`                                                                      | 0: non, 1: 1er prix, 2: 2e, 3: 3e            |
| 4   |                                                                                                                |                                              |
| 5   |                                                                                                                |                                              |
| 6   |                                                                                                                |                                              |
| 7   |                                                                                                                |                                              |
| 8   |                                                                                                                |                                              |

### Notes obtenues

**`note1`**, est la note obtenue pour les présélections, pour tous les projets.

**`note2`** est la note obtenue lors de la sélection finale par les projets présélectionnés (note : la première doit être obligatoirement supérieure aux notes des autres projets non présélectionnés mais cette note-ci peut être inférieure, puisque le jury peut se montrer plus dur.)

---

## Évaluations

Les évaluations fonctionnent en deux temps :

* **phase 2**. C’est la phase où sont produites les premières fiches d’évaluation qui vont permettre de choisir les 10 synopsis pour la finale. Leur nom est `evaluation-<id evaluateur>.json`.
* **phase 3**. C’est la phase où sont produites les secondes fiches d’évaluation qui vont permettre de déterminer les trois lauréats du concours. Leur nom est `evaluation-prix-<id evaluateur>.json`. Quand un évaluateur appartient aux deux jurys, il repart de sa fiche d’évaluation qui est automatiquement dupliquée.

---

## Envoi de mailing

L’envoi de mails est facilité pour le concours (le fonctionnement doit d’ailleurs être repris sur le site [Note du 25 octobre 2020]).

Pour commencer, tous les mails sont écrits dans le dossier :

```bash
./_lib/_pages_/concours/xmodules/mails
```

Ensuite, une classe intermédiaire `MailSender` se charge de l’envoi en nombre, il suffit de lui envoyer la liste des destinataires, le nom du mail dans le dossier ci-dessus et quelques options (pour préciser par exemple qu’il ne faut pas envoyer vraiment le mail mais seulement simuler la commande — mode `:noop`).

```ruby
MailSender.send([destinataires], "nom_mail", {options})
```

Avec :

```ruby
destinataires = [
  {pseudo: "pseudo", mail: "mail"[, autre_data: "facultatif"]},
  idem, idem, idem
 ]

nom_mail = "nom_du_fichier_dans_dossier_mails"

options = {
  noop: true,                # Simuler seulement si TRUE
  doit: true,                # Confirmation qu'il faut le faire si TRUE et si :noop est false
}
```

#### Titre du mail

C’est ici que la démarche est largement simplement : dans le mail (i.e. dans le fichier ERB), il suffit d’utiliser la méthode `subject("Titre du mail")` pour définir le `subject` du mail. De cette manière, message du mail et sujet du mail sont toujours associés.

#### Contenu du mail

Dans le mail, on utilise deux sortes de variables :

* Les variables ERB (`<%= ... %>`) qui seront renseignées au déserbage,
* Les variables template ruby (`%{…}`) qui seront évaluées au moment de l’envoi, avec les données des destinataires. À commencer par le pseudo.

```ERB
<p>
  Bonjours %{pseudo},
</p>
<p>
  Nous sommes cette année en <%= Time.now.year %> et votre mail est %{mail}.
</p>
<%= signature %>
```

---------------------------------------------------------------------

## Le Jury

Pour le moment, les membres du jury sont définis dans le fichier `./_lib/data/secret/concours.rb`, dans la données `CONCOURS_DATA[:evaluators]`

Dans le programme, un évaluateur est une classe `Evaluator`.

### Exécuter une action sur l'ensemble des membres du jury

```ruby
Evalutors.each do |evaluator|
  # evaluator est une instance {Evaluator}
  # ... action ...
end
```

### Envoi de mails aux jurys

```ruby
Evaluators.send(file:"le/path/au/fichier", jury:1|2|3)
```

> Note jury: 3 signifie les membres du jury qui appartiennent aux deux impérativement.

---------------------------------------------------------------------

## Résultats (messages)

Dès qu’il faut produire un résultat en plusieurs lignes, qui s’étend sur plusieurs méthodes, on peut utiliser `html.res <<` (ou simplement `res << ` dans une méthode d’instance de la classe `HTML`). Dans la page, il suffit ensuite d’utiliser `<%= resultat %>` (si l’instance `HTML` est bindée) ou `<%= html.resultat %>` (dans le cas contraire) pour afficher ce résultat et le réinitialiser.

#### Ajout d’un message de résultat

```ruby
html.res << "Mon message de résultat"
```

#### Affichage du résultat

```erb
<%= resultat %>

<%= html.resultat %>
```

# Fichier des palmarès

Le fichier des palmarès est un fichier `YAML` qui contient tout ce qu'il faut savoir pour produire la section des résultats (`concours/palmares`). Ce fichier contient :

```yaml
---
:infos:
  :annee: <année>
  :nombre_inscriptions: <integer> # donc tout confondu
  :nombre_concurrents:  <integer> # avec dossier conforme
  :nombre_sans_dossier: <integer>
  :nombre_non_conforme: <integer>
:classement:
  - :concurrent_id: <id>
    :note: <note générale>
  - :concurrent_id: <id>
    :note: <note générale>
  # etc. dans l'ordre décroissant des notes
  # Note : les 10 premiers sont susceptibles de bouger entre
  # la phase 3 et la phase 5
:non_conforme: # liste des concurrents avec un dossier non conforme
  - <id concurrent>
  - <id concurrent>
  # etc.
:sans_dossier: # liste des concurrents sans dossier
  - <id concurrent>
  - <id concurrent>
```
