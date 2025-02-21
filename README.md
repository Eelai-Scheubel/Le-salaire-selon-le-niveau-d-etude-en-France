# Analyse des salaires selon le niveau d'étude en France

## Description du projet

Ce projet vise à analyser l'impact du niveau d'études sur le salaire en France à l'aide du langage SAS. L'étude repose sur des données issues des Fichiers de Production et de Recherche (FPR), qui sont des données pseudonymisées accessibles uniquement aux chercheurs habilités par le Comité du secret statistique.

L'analyse inclut :

- La distribution des salaires (via log-salaire) et des variables explicatives.
- Une estimation de l'impact du niveau d'étude sur le salaire à l'aide de modèles de régression.
- Une étude des problèmes de multicolinéarité et des solutions pour les contourner.
- L'interprétation des coefficients obtenus et des prédictions issues des modèles.
- La comparaison des différents modèles afin de choisir le plus pertinent.

## Données

Les données utilisées proviennent des Fichiers de Production et de Recherche (FPR). L'accès à ces fichiers est soumis à des conditions strictes :

- Il est nécessaire d'être habilité par le Comité du secret statistique.
- Les données sont pseudonymisées et ne permettent pas l'identification directe des individus.
- **Il est interdit de publier ou partager ces données sur GitHub ou toute autre plateforme publique.**

## Installation et utilisation

### Prérequis

- SAS
  
## Méthodologie

1. **Exploration des données** : histogrammes et statistiques descriptives.
2. **Modélisation** : estimation par régression avec prise en compte des différents niveaux d'études.
3. **Correction de la multicolinéarité** : références croisées, modèles sans constante, régression avec moyenne de référence.
4. **Interprétation des résultats** : analyse des coefficients et comparaison des modèles.

## Résultats principaux

- L'effet positif du niveau d'étude sur le salaire est confirmé.
- La prise en compte du log-salaire permet de limiter l'influence des valeurs extrêmes.
- Le modèle avec référence au niveau primaire est le plus pertinent pour l'interprétation économique.

## Auteur

Projet réalisé dans le cadre d'une analyse économique avec des méthodes de data science appliquées au salaire et à l'éducation en France.

## Licence
Les données restent soumises aux restrictions des Fichiers de Production et de Recherche. **Toute diffusion non autorisée des données est strictement interdite.**

