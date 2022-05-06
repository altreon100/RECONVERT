model tutorial_gis_city_traffic

global {
	file shape_file_buildings <- file("../includes/RECONVERT/lille.shp"); // Fichier shape contenant les bâtiments de la zone à étudier
	file shape_file_bounds <- file("../includes/RECONVERT/bounds.shp"); //Fichier shape d'un rectangle contenant la zone choisi 
	geometry shape <- envelope(shape_file_bounds); //Limite à la zone simulée 
	float step <- 10 #mn; //correspond au temps entre chaque cycle 
	int nb_people<-20; // nombre d'unité opérative 
	int id<-0; // l'id de tout les bâtiment 
	int nb_building<-0; // calcul en temps réel le nombre de bâtiment qui reste à déconstruire 
	int nb_contrat<-0; // calcul en temps réel le nombre de contrat qui reste 
	
	init {
		create building  from: shape_file_buildings with: [type::string(read ("adedpe2056"))]{ //On lit la donnée dans le tableau qui donne le type du bâtiment
			if type="Non résidentiel" { // On considère qu'il s'agit d'un centre de tri et on lui affecte les valeurs de départ
				color <- #red ;
				brique <-0.0;
				verre <-0.0;
				bois <- 0.0;
				pvc <- 0.0;
				beton <-0.0;
				pierre <- 0.0;
				capacite<-70.0;
				id_building<-id+1;
				id<-id+1;
			}
			else{ // Sinon il s'agit d'un bâtiment à déconstruire
				color <- #blue;
				brique <- rnd(30.0);
				verre <-rnd(15.0);
				bois <-rnd(40.0);
				pvc<-rnd(25.0);
				beton<-rnd(20.0);
				pierre<-rnd(40.0);
				mat_total<- brique+verre+bois+pvc+beton+pierre;
				id_building<-id+1;
				nb_building<-nb_building+1;
				nb_contrat<-nb_contrat+1;
				id<-id+1;
			}
			
		}
		list<building> residence_buildings <- building where (each.type != "Non résidentiel"); // On crée une liste des bâtiment à déconstruire
		list<building> centre_trait<-building where (each.type="Non résidentiel");//On crée une liste des centre de tri
		
		create people number: nb_people {
			batiment<-one_of(residence_buildings);
			location <- any_location_in (batiment); // on affecte à l'agent une localisation aléatoire en choississant 1 bâtiment de la liste
			nb_contrat<-nb_contrat-1;
			id_person<-batiment.id_building;
			batiment.deconstruction<-true;
			list_bat<-residence_buildings;
			materiaux<-batiment.mat_total;
			list_traitement<-centre_trait;
			distance<-list_with(length(list_traitement),0.0);
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			tmp_dist<-copy(distance);
			tmp_centre<-copy(list_traitement);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_traitement)-1{ // On classe  la liste des centre de tri par ordre croissant de distance
				loop j from:0 to: length(list_traitement)-1{
					if(distance[i]=tmp_dist[j]){
						list_traitement[i]<-tmp_centre[j];
					}
				}
			}
			centre_tri<-list_traitement[0]; // Le centre de tri principal de l'agent est celui le plus proche
			speed<-3#km/#h; // Correspond à la vitesse de déplacement de l'agent lors du changement de bâtiment
		}
	}
}

species building { 
	string type; // le type du bâtiment (résidentiel ou pas )
	rgb color;
	// correspond aux différents matériaux du bâtiment
	float brique;
	float verre;
	float bois;
	float pvc;
	float beton;
	float pierre;
	
	float mat_total; // Calcul du total de matériaux restant 
	int id_building; // L'id du bâtiment
	float capacite; // Pour les centre de tri correspond à la capacité maximale du centre
	bool deconstruction<-false; // Si le bâtiment est en cours de déconstruction
	
	
	init{
	}
	// Pour les centre de tri les reflex decay_typeMatériaux réduisent la quantité du  matériaux d'un certains nombre et augmente la capacité
	reflex decay_brique when:color=#red{
		if(brique>0.4){
			brique<-brique-0.4;
			capacite<-capacite+0.4;
		}
		else{
			brique<-0.0;
			capacite<-capacite+brique;
		}
	}
	reflex decay_verre when:color=#red{
		if(verre>0.3){
			verre<-verre-0.3;
			capacite<-capacite+0.3;
		}
		else{
			verre<-0.0;
			capacite<-capacite+verre;
		}
	}
	reflex decay_bois when:color=#red{
		if(bois>0.5){
			bois<-bois-0.5;
			capacite<-capacite+0.5;
		}
		else{
			bois<-0.0;
			capacite<-capacite+bois;
		}
	}
	reflex decay_pierre when:color=#red{
		if(pierre>0.5){
			pierre<-pierre-0.5;
			capacite<-capacite+0.5;
		}
		else{
			pierre<-0.0;
			capacite<-capacite+pierre;
		}
	}
	reflex decay_beton when:color=#red{
		if(beton>0.4){
			beton<-beton-0.4;
			capacite<-capacite+0.4;
		}
		else{
			beton<-0.0;
			capacite<-capacite+beton;
		}
	}
	reflex decay_pvc when:color=#red{
		if(pvc>0.3){
			pvc<-pvc-0.3;
			capacite<-capacite+0.3;
		}
		else{
			pvc<-0.0;
			capacite<-capacite+pvc;
		}
	}
	reflex tot{ // calcul le total de matériaux restant 
		mat_total<- brique+verre+bois+pvc+beton+pierre;
	}
	
	
	reflex die when: color=#black{  // Si le bâtiment a finit d'être déconstruit on le tue
		do die;
	}
	aspect base {  
		draw shape color: color ;
	}
}

species people skills:[moving]{ // Unité opérative
	rgb color<- #yellow;
	float materiaux; // Correspond au total de matériaux restant
	int id_person;
	int id_tri; // id du centre de tri
	building batiment<-nil; // bâtiment sur lequel l'agent travaille
	building centre_tri<-nil; // centre de tri le plus proche
	point the_target<-nil; //Pointe sur le prochain bâtiment à déconstruire
	list<building> list_bat<-nil; // liste de tous les bâtiments
	list<building>list_traitement<-nil; // liste de tous les centres de tri
	list<building> tmp_centre<-nil;
	list<float> distance<-nil; // liste des distances aux centres de tri
	list<float> tmp_dist<-nil;
	bool find_new_centre<-false; // Pour trouver un autre centre si le plus proche est rempli
	
	
	
	
	/*	  init{
		*ask building{
			*if self.location = myself.location{
			myself.materiaux<- self.mat_total;
			myself.id_person<-self.id_building;
			}
			}
		}*/
	// Les decay_matériaux diminue le matériaux d'un certain nombre et l'envoi dans le centre de tri le plus proche
	reflex decay_brique when: nb_building!=0 and batiment.color=#blue{
		find_new_centre<-false;
		if batiment.brique>4.0{
			batiment.brique<-batiment.brique -4.0;
			if(centre_tri.capacite>=4.0){
				centre_tri.brique<-centre_tri.brique+4.0;
				centre_tri.capacite<-centre_tri.capacite-4.0;
			}
			else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=4.0 and find_new_centre=false){
						batiment.brique<-batiment.brique-4.0;
						list_traitement[i].brique<-list_traitement[i].brique+4.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-4.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.brique){
				centre_tri.brique<-centre_tri.brique+batiment.brique;
				centre_tri.capacite<-centre_tri.capacite-batiment.brique;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.brique and find_new_centre=false){
						list_traitement[i].brique<-list_traitement[i].brique+batiment.brique;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.brique;
						find_new_centre<-true;
					}
				}
			}
			batiment.brique<-0.0;
		}		
	}
	reflex decay_verre when: nb_building!=0 and batiment.color=#blue and batiment.brique=0{
		find_new_centre<-false;
		if batiment.verre>3.0{
			batiment.verre<-batiment.verre -3.0;
			if(centre_tri.capacite>=3.0){
				centre_tri.verre<-centre_tri.verre+3.0;
				centre_tri.capacite<-centre_tri.capacite-3.0;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=3.0 and find_new_centre=false){
						batiment.verre<-batiment.verre-3.0;
						list_traitement[i].verre<-list_traitement[i].verre+3.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-3.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.verre){
				centre_tri.verre<-centre_tri.verre+batiment.verre;
				centre_tri.capacite<-centre_tri.capacite-batiment.verre;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.verre and find_new_centre=false){
						list_traitement[i].verre<-list_traitement[i].verre+batiment.verre;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.verre;
						find_new_centre<-true;
					}
				}
			}
			batiment.verre<-0.0;
		}		
	}
	reflex decay_bois when: nb_building!=0 and batiment.color=#blue and batiment.verre=0 and batiment.brique=0{
		find_new_centre<-false;
		if batiment.bois>5.0{
			batiment.bois<-batiment.bois -5.0;
			if(centre_tri.capacite>=5.0){
				centre_tri.bois<-centre_tri.bois+5.0;
				centre_tri.capacite<-centre_tri.capacite-5.0;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=5.0 and find_new_centre=false){
						batiment.bois<-batiment.bois-5.0;
						list_traitement[i].bois<-list_traitement[i].bois+5.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-5.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.bois){
				centre_tri.bois<-centre_tri.bois+batiment.bois;
				centre_tri.capacite<-centre_tri.capacite-batiment.bois;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.bois and find_new_centre=false){
						list_traitement[i].bois<-list_traitement[i].bois+batiment.bois;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.bois;
						find_new_centre<-true;
					}
				}
			}
			batiment.bois<-0.0;
		}		
	}
	reflex decay_pierre when: nb_building!=0 and batiment.color=#blue and batiment.bois=0 and batiment.verre=0 and batiment.brique=0{
		find_new_centre<-false;
		if batiment.pierre>5.0{
			batiment.pierre<-batiment.pierre -5.0;
			if(centre_tri.capacite>=5.0){
				centre_tri.pierre<-centre_tri.pierre+5.0;
				centre_tri.capacite<-centre_tri.capacite-5.0;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=5.0 and find_new_centre=false){
						batiment.pierre<-batiment.pierre-5.0;
						list_traitement[i].pierre<-list_traitement[i].pierre+5.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-5.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.pierre){
				centre_tri.pierre<-centre_tri.pierre+batiment.pierre;
				centre_tri.capacite<-centre_tri.capacite-batiment.pierre;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.pierre and find_new_centre=false){
						list_traitement[i].pierre<-list_traitement[i].bois+batiment.pierre;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.pierre;
						find_new_centre<-true;
					}
				}
			}
			batiment.pierre<-0.0;
		}		
	}
	reflex decay_beton when: nb_building!=0 and batiment.color=#blue and batiment.pierre=0 and batiment.bois=0 and batiment.verre=0 and batiment.brique=0{
		find_new_centre<-false;
		if batiment.beton>4.0{
			batiment.beton<-batiment.beton -4.0;
			if(centre_tri.capacite>=4.0){
				centre_tri.beton<-centre_tri.beton+4.0;
				centre_tri.capacite<-centre_tri.capacite-4.0;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=4.0 and find_new_centre=false){
						batiment.beton<-batiment.beton-4.0;
						list_traitement[i].beton<-list_traitement[i].beton+4.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-4.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.beton){
				centre_tri.beton<-centre_tri.beton+batiment.beton;
				centre_tri.capacite<-centre_tri.capacite-batiment.beton;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.beton and find_new_centre=false){
						list_traitement[i].beton<-list_traitement[i].brique+batiment.beton;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.beton;
						find_new_centre<-true;
					}
				}
			}
			batiment.beton<-0.0;
		}		
	}
	reflex decay_pvc when: nb_building!=0 and batiment.color=#blue and batiment.beton=0 and batiment.pierre=0 and batiment.bois=0 and batiment.verre=0 and batiment.brique=0{
		find_new_centre<-false;
		if batiment.pvc>3.0{
			batiment.pvc<-batiment.pvc -3.0;
			if(centre_tri.capacite>=3.0){
				centre_tri.pvc<-centre_tri.pvc+3.0;
				centre_tri.capacite<-centre_tri.capacite-3.0;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=3.0 and find_new_centre=false){
						batiment.pvc<-batiment.pvc-3.0;
						list_traitement[i].pvc<-list_traitement[i].pvc+3.0;
						list_traitement[i].capacite<-list_traitement[i].capacite-3.0;
						find_new_centre<-true;
					}
				}
			}
		}
		else{
			if(centre_tri.capacite>=batiment.pvc){
				centre_tri.pvc<-centre_tri.pvc+batiment.pvc;
				centre_tri.capacite<-centre_tri.capacite-batiment.pvc;
			}
			else{
				loop i from:0 to:length(list_traitement)-1{
					if(list_traitement[i].capacite>=batiment.pvc and find_new_centre=false){
						list_traitement[i].pvc<-list_traitement[i].verre+batiment.pvc;
						list_traitement[i].capacite<-list_traitement[i].capacite-batiment.pvc;
						find_new_centre<-true;
					}
				}
			}
			batiment.pvc<-0.0;
		}		
	}
					
	reflex MAJ_bat when:nb_building!=0 and batiment.color!=#black { // On met à jour le montant total des matériaux. Si cela vaut 0 on passe la couleur du bâtiment à noir
		materiaux<-batiment.mat_total;
		id_person<-batiment.id_building;
		if materiaux=0{
			batiment.color<-#black;
			
		}
		}
	reflex change when:nb_contrat!=0 and batiment.color=#black { // Quand le bâtiment est déconstruit on reprend un nouveau bâtiment dans la liste
		list_bat<- building where (each.type != "Non résidentiel" and each.color=#blue and each.deconstruction=false);
		if(list_bat!=nil){
		batiment<-one_of(list_bat);
		the_target<-any_location_in(batiment);
		nb_contrat<-nb_contrat-1;
		nb_building<-nb_building-1;
		batiment.deconstruction<-true;
		
		}
		}
	
	
	reflex move when: the_target !=nil{ // permet le déplacement de l'agent vers le nouveau bâtiment
		do goto target:the_target ;
		if the_target=location{
			the_target<-nil;
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			tmp_dist<-copy(distance);
			tmp_centre<-copy(list_traitement);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_traitement)-1{ // On classe  la liste des centre de tri par ordre croissant de distance
				loop j from:0 to: length(list_traitement)-1{
					if(distance[i]=tmp_dist[j]){
						list_traitement[i]<-tmp_centre[j];
					}
				}
			}
			centre_tri<-list_traitement[0];
		}
	}
	
	reflex die when:nb_contrat=0 and batiment.color=#black{ // Quand tous les bâtiments sont déconstruits on tue les unité opérative
		nb_building<-nb_building-1;
		do die;
	}
	
	aspect base{
		draw circle(30) color: color border: #black;
	}
}


experiment road_traffic type: gui {
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the bounds:" var: shape_file_bounds category: "GIS" ;
	parameter "Number of people agents" var:nb_people category:"People";

		
	output {
		display city_display type:opengl {
			species building aspect: base ;
			species people aspect: base;
		}
		monitor "Number of building" value:nb_building;
		monitor "Number of contrat" value:nb_contrat;
	}
}