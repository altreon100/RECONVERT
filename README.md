# Simulation Basée Agent pour RECONVERT

Se repertoire organise les éléments utile à la Simulation Basé Agent pour le project RECONVERT.
La simulation s'appuye sur la platfom-Gama.

Pour plus de détail sur:

- le projet : [./doc/reconvert.md](doc/reconvert.md).
- la platforme GAMA : [https://gama-platform.org](gama-platform.org)

# INSTALLATION DE LA SOLUTION


# PRISE EN MAIN DE LA SOLUTION RECONVERT


Le projet Reconvert s'inscrit dans une démarche de recyclage des matériaux lors de la déconstruction des bâtiments. Le but serait de faire une déconstruction sélective des bâtiments et d'organiser des flux de produits et matériaux qui en sont issus pour un recyclage à une échelle locale. Le projet se positionne sur la métropole européenne de Lille (MEL) dans le cadre d'un partenariat entre cette dernière, les chercheurs de l'école IMT Nord Europe et d'acteurs du BTP (Rabot Dutilleul).





# SIMULATION GAMA

Une fois les différents documents du dossier "includes" téléchargés il faut les mettre dans GAMA. Une fois GAMA ouvert, il faut soit créer soit ouvrir votre projet GAMA dans "User models" (clique droit->new->GAMA projets). Une fois ce dossier créé vous avez 2 dossiers dedans: includes et models. Dans le dossier models il vous suffit d'importer le fichier .gaml et dans le dossier includes importer les différents fichiers (clique droit-> import->external files from disk). Avec ces différentes importations vous pouvez maintenant lancer la simulation.

# RECONVERT_V1
Cette version correspond à la 1er étape et de base pour la suite et n'a pas vocation à être utilisé
Dans cette première version il n'y a que 2 agents:
-les unités opératives qui déconstruisent les bâtiments
-les bâtiments (stockage,tri,bâtiment à déconstruire) suivant leur couleurs et étant basé sur 1 seul fichier QGIS 
En lançant la simulation dans l'onglet "information" il y a un graphe du taux d'occupation des centres de tri en fonction du temps 

# RECONVERT_V2

Dans cette nouvelle version il y a 5 agents:
-les unités opératives qui déconstruisent les bâtiments et envoie vers les centres de tri/stockage/valorisation
-les centres de stockage (enfouissement) qui ont une forte capacité et dont aucun matériaux ne sort 
-les centres de tri qui permettent de trier et d'envoyer ensuite en centre de valorisation ou de stockage
-les centres de valorisation qui permettent le recyclage des matériaux et donc le point central de cette étude 
-les bâtiments à déconstruire

Chacun de ces 4 bâtiments à son propre fichier QGIS et sa couleur afin de mieux les situer sur la carte finale 
Dans l'onglet information on peut voir le graphe du taux d'occupation des centres de tri et des centres de valorisation en fonction du temps 
La liste et l'ordre de sortie des matériaux est donné par des fichiers CSV 
Enfin un pourcentage de chaque matériaux déconstruit est envoyé à chaque centre. Ce pourcentage est influé par la note que l'on donne à la simulation (ex:Note 0 =pas de valorisation, Note 4 = version idéale beaucoup de valorisation et peu d'enfouissement).
