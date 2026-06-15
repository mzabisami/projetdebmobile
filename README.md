# EcoSafe - devmobile

Application Flutter de mobilité éco-responsable avec carte, transports, sécurité, profil et boutique de récompenses.

## Lancer le projet

```powershell
C:\flutter_sdk\bin\flutter.bat pub get
C:\flutter_sdk\bin\flutter.bat run -d chrome
```

## Structure principale

```text
lib/
|-- main.dart
|-- carte.dart
|-- config/
|   `-- theme.dart
|-- navigation/
|   `-- tab_nav.dart
|-- screens/
|   |-- safety_screen.dart
|   |-- profile_screen.dart
|   |-- stats_screen.dart
|   `-- shop_screen.dart
|-- data/
|   `-- rewards.json
|-- mocks/
|   `-- mock_data.dart
|-- modeles/
`-- services/
```

## Partie Dev 4

- Boutique complète en mode mock.
- Solde initial local : `320 pts`.
- Catalogue des récompenses dans `lib/data/rewards.json`.
- Échange local : vérifie le solde, déduit les points et confirme avec une notification.
- Navigation commune avec les onglets Carte, Transport, Sécurité, Profil et Boutique.
- L'onglet Boutique démarre par défaut pour faciliter la démo Dev 4.

## Intégration

- Firebase est initialisé dans `main.dart` depuis la version distante pullée.
- Les écrans Sécurité et Profil récupérés du pull sont branchés dans la navigation.
- L'écran Transport reste un placeholder jusqu'au merge du travail Dev 2.

## Future structure Firebase boutique

La boutique reste mockée dans cette version. La structure prévue pour la suite :

- `users` : profil utilisateur anonyme et solde de points.
- `trips` : historique des trajets.
- `points` : transactions de gain et dépense.
- `rewards` : catalogue des récompenses et disponibilités.

## Validation

```powershell
C:\flutter_sdk\bin\flutter.bat analyze
C:\flutter_sdk\bin\flutter.bat test
```
