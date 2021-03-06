
﻿# TP docker Vargiolu Thomas

## [](https://github.com/thomas-vargiolu/TP1)TP 1

### [](https://github.com/thomas-vargiolu/TP1)Database

On crée le docker en utilisant postgres:11.6-alpin et on build l'image avec  `docker build -t thomasvargiolu/database.`Run nous permet de le démarrer docker run --name...
   
Pour acceder à la base de donnée j'utilise dbeaver. J'ai quand meme créé un network pour plus tard du nom de reseau.

Le paramètre -e nous permet de donner les variables d'environnement pour éviter d'écrire les identifiants à la BD dans le Dockerfile mais alonge la commande.

Pour la persistance des données on accroche un volume fixe à notre dockerfile avec -v. Le volume permet de maintenir les données au docker après sa suppression.

### Backend API
```

#  java JRE
FROM openjdk:11

# java (aka bytecode, aka .class)
COPY . /usr/src/java
WORKDIR /usr/src/java
  
# Run the Java with: “java Main” command.
RUN javac Main.java
CMD ["java", "Main"] 

On exécute  `docker run --name java java`  et  on obtient `Hello world` .


# Build
# On nomme notre jdk via AS myapp-build qu'on pourra réutiliser ensuite pour le run
# Le jdk permet de compiler le java
FROM  maven:3.6.3-jdk-11  AS  myapp-build

#On se place dans un dossier
ENV  MYAPP_HOME  /opt/myapp
WORKDIR  $MYAPP_HOME

# On copie le fichier de conf pour build
COPY  pom.xml  .

# On copie tous les fichiers du projet à build
COPY  src  ./src

# On lance le build via maven
RUN  mvn  package  -DskipTests  dependency:go-offline

# Run
# On part d'une image plus simple pour avoir une empreinte mémoire plus légère
FROM  openjdk:11-jre
ENV  MYAPP_HOME  /opt/myapp
WORKDIR  $MYAPP_HOME

# On construie notre .jar via les fichiers qu'on vient de build au stage précédent
COPY  --from=myapp-build  $MYAPP_HOME/target/*.jar  $MYAPP_HOME/myapp.jar

# Les commandes à exécuter au run
ENTRYPOINT  java  -jar  myapp.jar
```
 On build le projet `docker build -t... .`On run le docker avec le port (8080) pour accéder à l'API :  `docker run -p 8090:8080 --name...`
Maintenant si on se rend sur [http://localhost:8080 on retrouve Hello world.



Après avoir récupérer le nouveau projet java, On modifie le fichier application.yml :
    -   url: databaseapp  _(le nom de mon container bd)_
    -   username: usr
    -   password: pwd
Puis on run le container :  `docker run --name kava3 -p 8080:8080 --net java3 thomasvargiolu/java3`
  `http://localhost:8080/departments/IRC/students`  nous permet de constater que l'a api backend lancée interroge bien ma BD et affiche le résultat

## HTTP Server


Image de base httpd
FROM  httpd:2.4
On crée un index et on excute in buid + run. L'index s'aficche sur le port 80 soit localhost:80
Commandes ;
- docker stats {id}`  :  indicateurs de consommation mémoire, CPU et autres  `
- docker inspect {id}`  : infos du container, les ports mobilisés, les connections tcp autorisées  `
- docker logs {id}`  : les logs affichés par le container 

### Configuration

Avec docker exec je récupère le fichier de config en local pour le modifier avant de le recopier sur le dockerfiles.  

### Reverse proxy
```
'# Image de base httpd
FROM  httpd:2.4

'# On copie nos fichiers dans le container
COPY  index.html  /usr/local/apache2/htdocs/
  
'# On rajoute notre configuration perso dans le container
COPY  httpd.conf  /usr/local/apache2/conf/httpd.conf
```
On a besoin d'un reverse proxy pour éviter que les clients interrogent directement notre API backend, cela sécurise en entrée notre application.

### Docker-compose

-   Docker-compose est un manager au-dessus de docker, on lui fourni des images à compiler

```
version: '3.3'  # La version de notre Docker compose
services: # Déclaration des services à builddpc
	java3:
		build: ./java3  # Le dossier où se situe notre Dockerfile à build
		networks: # On assigne notre container à un network
			- reseau
		depends_on: # On précise que notre service dépend d'un autre
			- database
	database:
		build: ./database
		networks:
			- reseau
	apache:
		build: ./apche
		ports: # La conversion de port
			- "8080:80"
		networks:
			- reseau
		depends_on:
			- java3
networks: # Déclaration des networks
	reseau:

```
  `docker-compose up` pour utiliser le docker-compose créé. Les ports du java3 et de la database ne seront pas ouverts

### Publish

On se connecte à docker hub :  `docker login` on crée  "tag" l'image de database :  `docker tag database thomasvargiolu/database:1.0`
Le tag permet de données une info sur la version du code posté. Il suffit ensuite de push pour compléter l'opération 


## TP 2

### Setup Github Actions

Testcontainers_ : classe Java qui permet de réaliser des tests unitaires par exemple des bases de données conteneurisées.
`mvn clean verify`  où se trouve le fichier pom.xml qui à les tests et les dépendances
```
name: CI devops 2022 CPE

on:

#to begin you want to launch this job in main and develop

push:

branches:

- main

- develop

pull_request:

jobs:

test-backend:

runs-on: ubuntu-18.04

steps:

#checkout your github code using actions/checkout@v2.3.3

- uses: actions/checkout@v2.3.3

#do the same with another action (actions/setup-java@v2) that enable to setup jdk 11

- name: Set up JDK 11

uses: actions/setup-java@v2

with:

java-version: '11'

distribution: 'adopt'

#finally build your app with the latest command

- name: Build and test with Maven

run: mvn clean verify --file ./java/simple-api-main/simple-api
```
On ajoute nos variables d'environnement via Git hub pour un soucis de sécurité.  On stock par exemple le token docker. 
La pipeline va ensuite builds nos images. On crée un job `needs: build-and-test-backend` et on rajoute le long à Docker hub dans les Push des images. 
Pendant un commit, on va donc d'abord test si le job test-backend passe puis build et push sur docker. 

### Setup Quality Gate
On config SonarClound en utilisant le TOKEN du projet et on rajoute au job les demandes de test. 

## TP 3

ansible all -m ping --private-key= -u centos

ansible all -i ansible/inventories/setup.yml -m ping

ansible-playbook -i ansible/inventories/setup.yml ansible/inventories/playbook.yml

ansible all -i inventories/setup.yml -m yum -a "name=httpd state=absent"
--become

thomas.vargiolu.takima.cloud | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    }, 
    "changed": false, 
    "msg": "Nothing to do", 
    "rc": 0, 
    "results": []
}


TASK [Test connection] *********************************************************
ok: [thomas.vargiolu.takima.cloud]

PLAY RECAP *********************************************************************
thomas.vargiolu.takima.cloud : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


