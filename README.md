# RECONVERT



Le projet Reconvert s'inscrit dans une démarche de recyclage des matériaux lors de la déconstruction des bâtiments. Le but serait de faire une déconstruction sélective des bâtiments et d'organiser des flux de produits et matériaux qui en sont issus pour un recyclage à une échelle locale. Le projet se positionne sur la métropole européenne de Lille (MEL) dans le cadre d'un partenariat entre cette dernière, les chercheurs de l'école IMT Nord Europe et d'acteurs du BTP (Rabot Dutilleul).

Ce projet est découpé en plusieurs thématique (numérique,environnemental,sociétal), ce répertoire git à pour but de rassembler les avancées de la thématique numérique.

# PARTIE NUMERIQUE

Dans le cadre de ce projet, il a été décidé de faire une simulation des différents bâtiments à déconstruire et de voir l'évolution des flux de matériaux au fil de leur déconstruction. Les agents doivent optimiser au mieux leur temps afin de déconstruire (voir reconstruire dans un second temps) les bâtiments le plus efficacement possible. Le simulateur GAMA a été choisi afin d'obtenir une SMA (Simulation Multi Agent) optimisé. Dans cette SMA nous avons plusieurs agents à savoir :

- les bâtiments à déconstruire 
- les zones de stockage/ressourcerie qui permettent aux matériaux récupérés d'être recyclés
- les unités opératives qui permettent la déconstruction des bâtiments

Afin de faire cette simulation, il a été necessaire de récupérer les données SIG(Système d'Information Géographique) de la MEL afin de pouvoir les traiter dans GAMA. Pour cela, il faut télécharger et installer QGIS sur votre PC via ce lien: https://www.qgis.org/fr/site/forusers/download.html.

Ensuite il faut télécharger les données SIG de la France grâce à ce lien :https://bdnb-data.s3.fr-par.scw.cloud/bnb_export.gpkg.zip

Ce dossier nous donne les informations des bâtiments en France classés selon leur année de construction ainsi que d'autre information comme par exemple le type de matériaux pour le toit et les murs. Une fois ouvert sur QGIS, vous pouvez récupérer la zone que vous voulait étudier (ici par exemple la MEL) en créant une couche qui effectue le contour de la zone avant de la couper grâce aux outils de géotraitement. Une fois découper et enregistré sous le format Shape vous pouvez importer les différents fichiers dans le dossier "include" de votre projet GAMA. Vous devez aussi enregistrer un rectangle de la zone à étudier également sous format Shape (ex:bounds.shp).

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
