# APK All Camera

Projet Flutter Android/iPhone pour centraliser des caméras IP et préparer des connecteurs pour les principaux écosystèmes chinois.

## Ce qui fonctionne dans cette V1

- ajout manuel de caméras ;
- catalogue des familles populaires ;
- lecture RTSP/HTTP avec VLC sur Android/iOS ;
- identifiants caméra intégrés dans l'URL de connexion ;
- liste locale persistante des caméras ;
- base extensible pour les connecteurs propriétaires ;
- build GitHub automatique d'un APK Android release.

## Ce qui nécessite encore le backend / SDK fabricant

- comptes Admin/Utilisateur partagés entre téléphones ;
- invitations et permissions à distance ;
- récupération du mot de passe par e-mail ;
- notifications push centralisées ;
- formatage SD/PTZ propriétaire quand le constructeur ne fournit pas ONVIF/API ;
- cloud P2P propriétaire V380/iCSee/UBox/VicoHome/etc. quand RTSP/ONVIF n'est pas exposé.

## Fabriquer l'APK sans installer Flutter sur le PC

1. Ouvrir l'onglet **Actions** > **Build Android APK**.
2. Lancer **Run workflow** ou pousser une modification sur `main`.
3. À la fin, télécharger l'artifact **APK-All-Camera**.
4. Le fichier obtenu est `APK-All-Camera.apk` et peut être installé sur Android.

La compilation iPhone utilise la même base Flutter mais nécessite la signature Apple adaptée au mode de distribution choisi.
