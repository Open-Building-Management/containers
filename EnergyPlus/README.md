# main goal

optimal restart : déterminer le bon moment pour relancer le chauffage avant l’arrivée des occupants

Un des sujets les plus intéressants en thermique du bâtiment !

# outils gravitant autour de la modélisation du bâtiment

Outil | Usage
--|--
Rhino | Modélisation géométrique / paramétrique haut niveau.
Revit | BIM + coordination de projets, pas simulation.
Pollination | Pont moderne entre géométrie/BIM et simulation physique. Plateforme d’ingénierie avancée basée sur EnergyPlus pour experts, avec workflows paramétriques.
Pleiades | Outil d’ingénieur thermicien orienté réglementation française et audits.
EnergyPlus | Moteur de simulation thermique et énergétique de bâtiments développé par le DOE (Department of Energy américain).

# build

```
docker build -t energyplus-python .
```

# epw files

epw = energy plus weather

https://climate.onebuilding.org

https://climate.onebuilding.org/WMO_Region_6_Europe/FRA_France/index.html

# idf files

Input Data File

# jupyter

run the jupyter server 

```
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser
```
