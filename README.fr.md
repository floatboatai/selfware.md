# Demo du Protocole Selfware

Langue : [English](README.md) | [中文](README.zh-CN.md) | [Italiano](README.it.md) | [日本語](README.ja.md) | **Français** | [Deutsch](README.de.md)

Ce dépôt est la version démo du **Protocole Selfware**, avec des modèles de brouillon en chinois et en anglais.

## Contenu Actuel

- `template.self/selfware-zh.md` : brouillon du protocole (édition chinoise)
- `template.self/selfware.md` : brouillon du protocole (édition anglaise)

Version actuelle du protocole : `v0.1.0 (Draft)`

## Qu'est-ce que Selfware

Selfware vise à définir un protocole de fichier unifié pour l'ère des Agents :

- A file is an app. Everything is a file.
- Les données, la logique et les vues peuvent être regroupées de manière optionnelle dans une seule unité distribuable (fichier unique ou conteneur `.self`).
- La collaboration est décentralisée entre les flux humain↔Agent et Agent↔Agent.

## Principes Clés (Résumé)

- **Canonical Data Authority** : chaque instance doit définir une source de vérité.
- **Write Scope Boundary** : les écritures doivent être limitées à `content/` (ou à une portée canonique équivalente déclarée).
- **No Silent Apply** : les mises à jour ne doivent pas être appliquées sans information et confirmation de l'utilisateur.
- **View as Function** : `View = f(Data, Intent, Rules)` ; les vues ne sont pas la source de vérité.

## Comment Utiliser

Pour une prise en main rapide, vous pouvez essayer cette démo : `https://github.com/awesome-selfware/openoffice.self`

1. Lire le brouillon chinois : `template.self/selfware-zh.md`
2. Lire le brouillon anglais : `template.self/selfware.md`
3. Créer votre propre fichier de protocole d'instance à partir de ces modèles, puis étendre les modules runtime selon vos besoins (API, packaging, collaboration, Memory, Discovery, etc.).

## Notes sur le Dépôt

- Ce dépôt contient actuellement uniquement des documents modèle du protocole.
- Une implémentation runtime/server complète n'est pas incluse.

## Licence

Le texte du protocole indique une licence MIT optionnelle (voir les fichiers du protocole pour les détails).

