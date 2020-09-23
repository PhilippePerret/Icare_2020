# Projet de réparation

Réflexion sur la production d'un script qui permet de contrôler la validité de toutes les données concerant les modules.

### Contrôle des IcModules

* Un icmodule doit avoir un abs-module de référence
* l'abs-module de référence d'un ic-module doit exister
* Un icmodule doit avoir des icetapes (forcément)
* les icetapes de l'icmodule doivent toutes exister
* une icetape de module doit être terminée, sauf si c'est la dernière
* les pauses doivent être bien définies

### Contrôle des icetapes

* une icetape doit avoir une abs-etape de référence
* l'abs-etape de l'ic-etape doit exister
* une icetape doit avoir un icmodule de référence
* l'icmodule de référence de l'icetape doit exister
* l'icetape doit être terminée sauf si c'est la dernière du module
* tous les documents de l'icetape doivent exister (avoir un enregistrement)
* tous les documents de l'icetape doivent posséder leur document sur le qdd

### Contrôle des documents

* un document doit avoir une icetape de référence
* l'icetape de référence du document doit exister.
