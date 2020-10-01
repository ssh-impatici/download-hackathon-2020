# Download Hackathon 2020 Team SSH-IMPATICI

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/header.jpeg" width="500">
</p>

> Beelder, a Flutter app with Firebase backend made in 48h for the Download Hackathon 2020

Download Innovation 2020: IT Conference & Festival (3rd Edition)

![alt text](https://img.shields.io/badge/Language-English-infomrmational?style=for-the-badge)

## Ideas

Beelder is an app for team building in any area (eg. Tech, Music, Football, Home Renovation...) based on common interests or proximity. This app can be used for a phase which precedes the project organization phase (eg. Task, To-do list...) already present in many applications on the internet (eg. Trello).

Metaphorically speaking and referring to the Hackathon theme, we have provided a platform where each user can view and register to nearby hives on the map, in which a hive is a group of people who are forming a team in some area with a detailed list of necessary roles. This can be compared to the decentralized propagation of information that bees use among each others for indicating the position of the flowers by dancing, so that all nearby or interested bees receive the information. In addition to this, each user can receive a notification regarding the creation of a new hive nearby with similar interests. The user can also filter the hives based on his interests and, if he wants, he can join the hives by applying for a required role. Each hive will therefore have many users and a queen bee in which each user independently knows and performs a specific task just as each bee knows which function to do, like searching for nectar or pollen or feeding the larvae.

We have also introduced the possibility for each user to create a new hive becoming its queen bee: the hive can also not own a position on the map and be virtual, for example in those areas where a physical presence among team members is not required (eg. Design of an app).

We believe that the dualism of live events (present on the map) and virtual events will be very present in the future, given the period that has just passed, and will certainly be a solution to be adopted also for next year's Download Innovation, both in terms of the mix of live and virtual events and the use of the Beelder app to search for participants and form new teams for the Hackathon.

## Quick Start

### Installation

This is a [Flutter](https://flutter.io) app. We provide you an apk file that you can install on your device. Since the app isn't distributed on the PlayStore platform, it will probably alerts you about some kind of risk. You can install it without any fear, it is completely safe.
If you want to build and run the app from source code on a device emulator on you computer, you can install Flutter following the [official documentation](https://flutter.io/docs/get-started/install) or, if you want to avoid the installation of Android Studio, you can follow [this great guide](https://medium.com/@quicky316/install-flutter-sdk-on-windows-without-android-studio-102fdf567ce4).

Once you have installed flutter, make sure to be in the `app` folder and to have installed the necessary plugins with `flutter pub get`.

This repo is using Firebase with Cloud Firestore as backend. You can read the [official documentation](https://firebase.google.com/docs). The code is in the `firebase` folder.

We provide a file named `beelder.apk` which can be installed on android devices running Android 4.1 (API level 16) or higher.

Firebase is online and available to handle past requests.

### Usage

Initially you have to sign up with the email address or by signing in with Google. After, you have to complete your profile by entering your data and selecting the topics you are interested in.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_1.jpg" width="200">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_2.jpg" width="200">
</p>

The first part displayed by the app is the `map` tab where you can see the hives, click on them for details or click the button at the bottom right to create one. The buttons at the bottom left are used to filter the hives  on the map according to your interests, reload the map and refocus the map on your position. To change tabs you need to use the nav bar.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_3.jpg" width="200">
</p>

To create an hive you will need to complete all the fields by entering the topics and the open roles also specifying the quantity (Note: if the hive is virtual, leave empty the location!).

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_4.jpg" width="200">
</p>

The `explore` tab shows all hives, both nearby ones (indicating their distance in km) and virtual ones. In addition to the various topics, a key icon is shown if you are the queen bee of the hive.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_5.jpg" width="200">
</p>

The `my hives` tab shows the hives that you have joined or owned. In the `hive's detail` tab you can apply for multiple roles or remove yourself and also, if you are the creator, you can give team members a star rating for the role played.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_6.jpg" width="200">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_7.jpg" width="200">
</p>

The `profile` tab show your informations, your bio, your interests and the specific rating of each role held in the past grouped by topic.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_8.jpg" width="200">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_9.jpg" width="200">
</p>

In addition you will be notified if a new hive is created nearby with topics relevant to yours.

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_10.jpg" width="500">
</p>

Note: use pull to refresh in the tabs!

## Authors

### Team SSH-IMPATICI

-   **Giorgio Bertolotti**: [Site](https://bertolotti.dev/)
-   **Lorenzo Conti**: [Site](https://www.lorenzoconti.dev/#/)
-   **Samuele Ferri**: [Site](https://samuelexferri.com)
-   **Fabio Sangregorio**: [Site](https://fabio.sangregorio.dev/)

<p align="center">
<img src="https://gitlab.com/download-event-2020/ssh_impatici/-/raw/master/images/screens/screen_11.jpg" width="200">
</p>

## Version

![alt text](https://img.shields.io/badge/Version-0.0.1-blue.svg?style=for-the-badge)

## License

[![License](https://img.shields.io/badge/License-MIT_License-blue.svg?style=for-the-badge)](https://badges.mit-license.org)
