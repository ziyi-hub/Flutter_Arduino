# Projet de Mobilité et Multimodalité
- Notre projet vise à guider un cycliste à suivre son itinéraire sans qu'il ait besoin de regarder son téléphone. L'idée de base consiste à utiliser notre téléphone pour récupérer notre position, notre orientation, et l'itinéraire grâce à des applications comme Google Maps, par exemple. Ensuite, nous transmettons ces données pour définir les modalités de sortie, afin de communiquer les actions à effectuer par le cycliste, comme les indications pour tourner, par exemple.

# Réalisation
- Application Mobile: qui récupère les données via l’API Google et les traite afin d'envoyer des commandes à une carte Arduino via une connexion Bluetooth. 
- Arduino: Recevoir un command depuis l’application, manipule la vibration (LED) gauche ou droite

