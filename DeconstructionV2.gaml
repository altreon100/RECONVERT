model tutorial_gis_city_traffic

global {
	file shape_file_buildings <- file("../includes/lille.shp"); // Fichier shape contenant les bâtiments de la zone à étudier
	file shape_file_bounds <- file("../includes/bounds.shp"); //Fichier shape d'un rectangle contenant la zone choisi
	file ordre_mat <- csv_file("../includes/001ORDER.csv");// Fichier contenant l'ordre de sortie des matériaux
	file note<-csv_file("../includes/002NOTE0.csv");
	file note1<-csv_file("../includes/003NOTE1.csv");
	file note2<-csv_file("../includes/004NOTE2.csv");
	file note3<-csv_file("../includes/005NOTE3.csv");
	file note4<-csv_file("../includes/006NOTE4.csv");
	geometry shape <- envelope(shape_file_bounds); //Limite à la zone simulée 
	float step <- 0.5#day; //correspond au temps entre chaque cycle 
	int nb_people<-5; // nombre d'unité opérative 
	int id<-0; // l'id de tout les bâtiment 
	int nb_building<-0; // calcul en temps réel le nombre de bâtiment qui reste à déconstruire 
	int nb_contrat<-0; // calcul en temps réel le nombre de contrat qui reste 
	float total_capacite<-0.0;// Permet de calculer le taux d'occupation des centres de tri
	float init_tot_capacite<-0.0;
	int nb_stockage<-0; // calcul le nombre de centre de stockage
	int nb_tri<-0; //calcul le nombre de centre de tri
	
	
	init {
		matrix<string> matrix_ordre <- matrix(ordre_mat);
		matrix<string> copy_mat<-copy(matrix_ordre);
		matrix<string> matrix_note<-matrix(note);
		
		point size<-[1,matrix_ordre.rows];
		int nb<-0;
		string ordre<-nil;
		loop i from: 1 to: 8{
		ordre<-string(i);
			loop j from: 0 to: matrix_ordre.rows -1{
				if(copy_mat[2,j] contains ordre){
					matrix_ordre[0,nb]<-copy_mat[0,j];
					matrix_ordre[1,nb]<-copy_mat[1,j];
					matrix_ordre[2,nb]<-copy_mat[2,j];
					nb<-nb+1;
				}
			}	
		}
		matrix<string>note_ordre<-nil;
		
		matrix_note<-transpose(matrix_note);
		point size2<-[matrix_note.columns,10];
		note_ordre<-matrix_with(size2,"0.0");
		
		
		loop i from: 0 to: matrix_note.columns-1{
				loop j from:0 to:matrix_note.columns-1{
					if(matrix_note[i,1]=matrix_ordre[1,j]){
						loop k from:2 to: matrix_note.rows-1{
							note_ordre[j,k-2]<-matrix_note[i,k];
						}
					}	
				}
				
		}
		note_ordre<-transpose(note_ordre);
		
		
		create building  number:500 from: shape_file_buildings with: [type::string(read ("adedpe2056"))]{ //On lit la donnée dans le tableau qui donne le type du bâtiment
			if type="Non résidentiel" { // On considère qu'il s'agit d'un centre de tri et on lui affecte les valeurs de départ
				if(id>=0 and id<20){ //Pour les 40 premiers bâtiments on suppose qu'ils sont des zones de stockage (capacité très forte)
					color <- #green ;
					capacite<-1000.0;
					id_building<-id+1;
					id<-id+1;
					nb_stockage<-nb_stockage+1;
					materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-0;
					}	
				}
				else{
				color <- #red;
				capacite<-70.0;
				total_capacite<-total_capacite+capacite;
				init_tot_capacite<-init_tot_capacite+capacite;
				id_building<-id+1;
				id<-id+1;
				nb_tri<-nb_tri+1;
				materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-0;
					}
				
				}
			}
			else{ // Sinon il s'agit d'un bâtiment à déconstruire
				color <- #blue;
				id_building<-id+1;
				nb_building<-nb_building+1;
				nb_contrat<-nb_contrat+1;
				id<-id+1;
				materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-rnd(30.0);
						mat_total<-mat_total+materiaux[0,i];
					}
			}
		}
		list<building> residence_buildings <- building where (each.type != "Non résidentiel"); // On crée une liste des bâtiment à déconstruire
		list<building> centre_trait<-building where (each.type="Non résidentiel" and each.color=#red);//On crée une liste des centre de tri
		list<building> centre_stockage<-building where (each.type="Non résidentiel" and each.color=#green);//On crée une liste des centre de stockage
		
		create people number: nb_people {
			batiment<-one_of(residence_buildings);
			location <- any_location_in (batiment); // on affecte à l'agent une localisation aléatoire en choississant 1 bâtiment de la liste
			nb_contrat<-nb_contrat-1;
			id_person<-batiment.id_building;
			batiment.deconstruction<-true;
			list_bat<-residence_buildings;
			materiaux<-batiment.mat_total;
			list_traitement<-centre_trait;
			list_stockage<-centre_stockage;
			distance<-list_with(length(list_traitement),0.0);
			distance_stock<-list_with(length(list_stockage),0.0);
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_stockage)-1{   // On calcule la distance entre l'agent et tous les centres de stockage existant
				ask list_stockage at i{
					myself.distance_stock[i]<-self distance_to myself;
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
			tmp_dist<-copy(distance_stock);
			tmp_centre<-copy(list_stockage);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_stockage)-1{ // On prend le centre de stockage le plus proche
					if(distance_stock[0]=tmp_dist[i]){
						centre_stock<-tmp_centre[i];
					}
				
			}
			centre_tri<-list_traitement[0]; // Le centre de tri principal de l'agent est celui le plus proche
			speed<-50#km/#h; // Correspond à la vitesse de déplacement de l'agent lors du changement de bâtiment
		}
	}
	
}

species building { 
	string type; // le type du bâtiment (résidentiel ou pas )
	rgb color;
	// correspond aux différents matériaux du bâtiment
	float mat_total<-0.0; // Calcul du total de matériaux restant 
	int id_building; // L'id du bâtiment
	float capacite; // Pour les centre de tri correspond à la capacité maximale du centre
	bool deconstruction<-false; // Si le bâtiment est en cours de déconstruction
	matrix<float>  materiaux<-nil;
	
	// Pour les centre de tri les reflex decay_typeMatériaux réduisent la quantité du  matériaux d'un certains nombre et augmente la capacité
	reflex decay when:color=#red{
		loop i from:0 to:materiaux.rows-1{
			if(materiaux[0,i]>0.4){
				materiaux[0,i]<-materiaux[0,i]-0.4;
				capacite<-capacite+0.4;
				total_capacite<-total_capacite+0.4;
			}
			else if(materiaux[0,i]>0.0){
				capacite<-capacite+materiaux[0,i];
				total_capacite<-total_capacite+materiaux[0,i];
				materiaux[0,i]<-0.0;
			}
		}
		
	}
			
	reflex tot{ // calcul le total de matériaux restant 
		mat_total<-0.0;
		loop i from:0 to:materiaux.rows-1{
			mat_total<-mat_total+materiaux[0,i];
		}
		
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
	building centre_stock<-nil; // centre de stockage le plus proche
	point the_target<-nil; //Pointe sur le prochain bâtiment à déconstruire
	list<building> list_bat<-nil; // liste de tous les bâtiments
	list<building>list_traitement<-nil; // liste de tous les centres de tri
	list<building> tmp_centre<-nil;
	list<building>list_stockage<-nil;
	list<float> distance<-nil; // liste des distances aux centres de tri
	list<float>distance_stock<-nil;
	list<float> tmp_dist<-nil;
	bool find_new_centre; // Pour trouver un autre centre si le plus proche est rempli
	bool sol;
	
	// Les decay diminue le matériaux d'un certain nombre et l'envoi dans le centre de tri le plus proche
	reflex decay when: nb_building!=0 and batiment.color=#blue {
		find_new_centre<-false;
		sol<-false;
		loop i from:0 to:batiment.materiaux.rows -1{
			if(batiment.materiaux[0,i]!=0.0 and sol=false){
				sol<-true;
				if batiment.materiaux[0,i]>10.0{
					batiment.materiaux[0,i]<-batiment.materiaux[0,i] -10.0;
					if(total_capacite=0.0){
						centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i]+10.0;
						centre_stock.capacite<-centre_stock.capacite-10.0;
					}
					else if(centre_tri.capacite>=10.0){
						centre_tri.materiaux[0,i]<-centre_tri.materiaux[0,i]+10.0;
						centre_tri.capacite<-centre_tri.capacite-10.0;
						total_capacite<-total_capacite-10.0;
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=10.0 and find_new_centre=false){
								list_traitement[j].materiaux[0,i]<-list_traitement[j].materiaux[0,i]+10.0;
								list_traitement[j].capacite<-list_traitement[j].capacite-10.0;
								total_capacite<-total_capacite-10.0;
								find_new_centre<-true;
							}
						}
					}
				}
				else{
					if(total_capacite=0.0){
						centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i]+batiment.materiaux[0,i];
						centre_stock.capacite<-centre_stock.capacite-batiment.materiaux[0,i];
					}
					else if(centre_tri.capacite>=batiment.materiaux[0,i]){
						centre_tri.materiaux[0,i]<-centre_tri.materiaux[0,i]+batiment.materiaux[0,i];
						centre_tri.capacite<-centre_tri.capacite-batiment.materiaux[0,i];
						total_capacite<-total_capacite-batiment.materiaux[0,i];
					}
					else{
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=batiment.materiaux[0,i] and find_new_centre=false){
								list_traitement[j].materiaux[0,i]<-list_traitement[j].materiaux[0,i]+batiment.materiaux[0,i];
								list_traitement[j].capacite<-list_traitement[j].capacite-batiment.materiaux[0,i];
								total_capacite<-total_capacite-batiment.materiaux[0,i];
								find_new_centre<-true;
							}
						}
					}
				batiment.materiaux[0,i]<-0.0;
				}
				
			}
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
			loop i from:0 to:length(list_stockage)-1{   // On calcule la distance entre l'agent et tous les centres de stockage existant
				ask list_stockage at i{
					myself.distance_stock[i]<-self distance_to myself;
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
			tmp_dist<-copy(distance_stock);
			tmp_centre<-copy(list_stockage);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_stockage)-1{ // On prend le centre de stockage le plus proche
					if(distance_stock[0]=tmp_dist[i]){
						centre_stock<-tmp_centre[i];
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

	output {
		display city_display type:opengl {
			species building aspect: base ;
			species people aspect: base;
		}
		display information refresh:every(5#cycles){
			chart "Taux d'occupation des centres de tri (en %)" type:series size:{1,0.5} position:{0,0}{
				data "tot_capacité" value:(1-(total_capacite/init_tot_capacite))*100 color:#red;
			}
		}
		monitor "Number of building" value: nb_building;
	}
}