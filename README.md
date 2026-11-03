<div align="center">

<img src="docs/icon.png" width="120" alt="Vivacidade app icon"/>

# Vivacidade

[![iOS](https://img.shields.io/badge/iOS-26%2B-000000?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)](https://swift.org)
[![UIKit](https://img.shields.io/badge/UIKit-ARKit%20%2B%20RealityKit-0A84FF)](https://developer.apple.com/augmented-reality/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Record audio memories and pin them to real places in augmented reality, so anyone passing by can hear them.

<a href="https://apps.apple.com/br/app/vivacidade/id6761855371">
  <img src="https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg" height="48" alt="Download on the App Store"/>
</a>

</div>

## Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Built With](#built-with)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Team](#team)
- [License](#license)

## About

Vivacidade ("city liveliness") was built at the Apple Developer Academy | Mackenzie
around one idea: give people back moments of contemplation in the city they cross
every day. Users record short audio memories and anchor them to places they choose,
using the iPhone camera and augmented reality. Each recording becomes a colored cube
floating in the real world that can be shared, so other people can live that moment
when they walk by the same spot. The app is published on the App Store and its UI is
in Portuguese.

## Features

- Record and play back audio memories with a live waveform
- Place each memory as a 3D object in the real world with ARKit and RealityKit
- Geolocated memories with Core Location and MapKit
- Library of recorded memories stored with Core Data
- Share a memory as a custom file; opening that file launches the app and imports it

## Screenshots

| Memories in AR | Pinned memory | Listening | Memory card |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/1.png" width="180"> | <img src="docs/screenshots/2.png" width="180"> | <img src="docs/screenshots/3.png" width="180"> | <img src="docs/screenshots/4.png" width="180"> |

## Built With

- UIKit with programmatic view controllers
- ARKit and RealityKit for world tracking and 3D anchors
- AVFoundation for recording and playback
- Core Data, Core Location, MapKit and Core Motion
- Custom document type with `UIDocument` and a document picker for sharing

## Getting Started

Requirements: Xcode 26 or later and an iPhone with iOS 26 (augmented reality does not
run in the Simulator).

```bash
git clone https://github.com/EnzoFerroni/Vivacidade.git
cd Vivacidade
open ProjectCidadeParaPessoas/ProjectCidadeParaPessoas.xcodeproj
```

Select your device, set your own signing team and press Run.

## Project Structure

```
ProjectCidadeParaPessoas/ProjectCidadeParaPessoas/
├── App/            AppDelegate, SceneDelegate
├── Controllers/    AR view, audio sheet, library, Core Data
├── Services/       Audio, Core Data, geolocation, sharing, sheets
├── Models/         CuboModel (an audio memory placed in the world)
├── ViewModels/     CustomARViewModel
├── Views/          AR view, waveform, playback timer, library cell
└── FilePicker/     Custom document type and picker
```

## Team

<div align="center">
  <table>
    <tr>
      <td align="center" width="25%">
        <a href="https://github.com/EnzoFerroni"><img src="https://github.com/EnzoFerroni.png" width="90" alt="Enzo Ferroni"/></a>
        <br/><sub><b>Enzo Ferroni</b></sub><br/><br/>
        <a href="https://github.com/EnzoFerroni"><img src="https://skillicons.dev/icons?i=github" alt="GitHub"/></a>
        <a href="https://www.linkedin.com/in/enzoferroni/"><img src="https://skillicons.dev/icons?i=linkedin" alt="LinkedIn"/></a>
      </td>
      <td align="center" width="25%">
        <a href="https://github.com/gsgonca"><img src="https://github.com/gsgonca.png" width="90" alt="Gabriel Gonçalves"/></a>
        <br/><sub><b>Gabriel Gonçalves</b></sub><br/><br/>
        <a href="https://github.com/gsgonca"><img src="https://skillicons.dev/icons?i=github" alt="GitHub"/></a>
        <a href="https://www.linkedin.com/in/gabriel-s-gon%C3%A7alves/"><img src="https://skillicons.dev/icons?i=linkedin" alt="LinkedIn"/></a>
      </td>
      <td align="center" width="25%">
        <a href="https://github.com/JonasFNMelo"><img src="https://github.com/JonasFNMelo.png" width="90" alt="Jonas Melo"/></a>
        <br/><sub><b>Jonas Melo</b></sub><br/><br/>
        <a href="https://github.com/JonasFNMelo"><img src="https://skillicons.dev/icons?i=github" alt="GitHub"/></a>
        <a href="https://www.linkedin.com/in/jonas-melo-/"><img src="https://skillicons.dev/icons?i=linkedin" alt="LinkedIn"/></a>
      </td>
      <td align="center" width="25%">
        <a href="https://github.com/TamiresMendesS"><img src="https://github.com/TamiresMendesS.png" width="90" alt="Tamires Mendes"/></a>
        <br/><sub><b>Tamires Mendes</b></sub><br/><br/>
        <a href="https://github.com/TamiresMendesS"><img src="https://skillicons.dev/icons?i=github" alt="GitHub"/></a>
        <a href="https://www.linkedin.com/in/tamires-mendes-6006792b7/"><img src="https://skillicons.dev/icons?i=linkedin" alt="LinkedIn"/></a>
      </td>
    </tr>
    <tr>
      <td align="center" width="25%">
        <a href="https://github.com/hyauss"><img src="https://github.com/hyauss.png" width="90" alt="Vinicius Marques"/></a>
        <br/><sub><b>Vinicius Marques</b></sub><br/><br/>
        <a href="https://github.com/hyauss"><img src="https://skillicons.dev/icons?i=github" alt="GitHub"/></a>
        <a href="https://www.linkedin.com/in/vinicius-marques-966918274/"><img src="https://skillicons.dev/icons?i=linkedin" alt="LinkedIn"/></a>
      </td>
    </tr>
  </table>
</div>

Fork of the team repository [C12G4/ProjectCidadeParaPessoas](https://github.com/C12G4/ProjectCidadeParaPessoas).

## License

Released under the [MIT License](LICENSE). Copyright (c) 2026 Enzo Ferroni, Gabriel Gonçalves, Jonas Melo, Tamires Mendes and
Vinicius Marques.
