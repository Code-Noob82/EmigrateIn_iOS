# EmigrateIn - Expat Familien App (MVP)

**Gut vorbereitet auswandern – mit EmigrateIn.**

## Projektbeschreibung

**EmigrateIn** *(Arbeitstitel, Name wird ggf. noch geändert)* ist eine native iOS-App, die als Minimum Viable Product (MVP) im Rahmen des **Abschlussprojekts Modul 3 - App-Entwicklung iOS - am Syntax Institut** entwickelt wurde.

## Ziel der App

Deutschen Familien den komplexen Prozess der Auswanderung nach Südzypern zu erleichtern. Die App soll als zentraler Informations-Hub und Begleiter dienen, um Unsicherheiten zu reduzieren und die Vorbereitung sowie die ersten Schritte nach der Ankunft zu strukturieren.

## Problemstellung

Die Auswanderung, besonders mit Familie, ist mit zahlreichen bürokratischen Hürden, Informationslücken und organisatorischem Aufwand verbunden. Informationen sind oft verstreut, veraltet oder nicht spezifisch auf die Bedürfnisse von Familien zugeschnitten.

## Lösungsansatz (MVP)

Die App bündelt relevante, recherchierte Informationen und interaktive Checklisten für die kritischen Phasen der Vorbereitung in Deutschland und der Ankunft in Südzypern. Sie nutzt Firebase als Backend und integriert eine externe API zur Anzeige relevanter Kontaktdaten.

## Was macht die App anders/besser?

Im Gegensatz zu allgemeinen Foren oder Webseiten, konzentriert sich EmigrateIn **gezielt auf deutsche Familien und den Start in Südzypern**. Sie bietet nicht nur Informationen, sondern **verknüpft diese direkt mit praktischen, interaktiven Checklisten**. Besonderer Wert wird auf die **Verlässlichkeit der Informationen** gelegt, indem auf offizielle Quellen verwiesen und der Informationsstand transparent gemacht wird.

## Kern-Features (MVP V1.0 - Fokus: Deutsche Familien nach Südzypern)

- [ ] **Onboarding:** Nach dem Start durchläuft der Nutzer ein kurzes Onboarding. Über eine Hauptnavigation (z.B. Tab Bar) kann er auf die verschiedenen Info-Kategorien und Checklisten zugreifen. Informationen können gelesen, Checklistenpunkte abgehakt werden. Die Botschaftsinformationen werden dynamisch über eine API geladen.
- [ ] **Info-Hub**: Ein strukturierter Bereich mit aufbereiteten Informationen zu essenziellen Themen:
- Visa & Einreise *(MEU1/Yellow Slip, MEU2)*
- Ankunft & Erste Schritte *(Behördengänge: TIN, Sozialversicherung, GESY)*
- Wohnen *(Mieten/Kaufen Basics, Mietvertrag, Nebenkosten)*
- Bildung & Familie *(Schulsystem Überblick, Anmeldung Basics)*
- Gesundheitssystem *(GESY Überblick, Registrierung, Arztsuche Basics)*
- Kosten & Budget *(Statische Übersicht Lebenshaltungskosten, Einmalkosten)*
- Kontakte & Sicherheit *(Botschafts-Info, Notfallnummern, Hinweise zur Sicherheitsrecherche)*
- [ ] **Interaktive Checklisten:** Detaillierte, abharkbare Checklisten für die Phasen:
- Vorbereitung in Deutschland
- Ankunft & Erste Schritte in Zypern
- Speicherung des Fortschritts lokal `(SwiftData)` oder via Firebase Authentication.
- [ ] **Botschafts-Information:** Abruf und Anzeige der Kontaktdaten der Deutschen Botschaft in Nikosia über die OpenData-API des Auswärtigen Amtes `(travelwarning.api.bund.dev)`.
- [ ] **Fehlerbehandlung:** Nutzerfreundliche Anzeige von Fehlern *(z.B. bei Netzwerkproblemen oder API-Fehlern)* mittels Alerts.

## Design

<p>
  <img src="./img/screen1.png" width="200">
</p>

## Technologie-Stack

- **Plattform:** iOS
- **Sprache:** Swift
- **UI-Framework:** SwiftUI
- **Architektur:** MVVM *(Model-View-ViewModel)*
- **Backend:** Google Firebase
  - Datenbank: Firestore *(für App-Inhalte wie Infos & Checklisten)*
  - Authentifizierung: Firebase Authentication *(Optional für MVP, z.B. zur Speicherung des Checklisten-Status)*
- **API-Anbindung:** `URLSession` mit `async/await` für den Aufruf der Auswärtiges-Amt-API.
- **Daten-Parsing:** `Codable`für JSON-Daten aus Firebase und der API.
- **Lokale Daten:** `SwiftData`für einfache Einstellungen oder Checklisten-Status.

#### Projektaufbau
Eine kurze Beschreibung deiner Ordnerstruktur und Architektur (MVVM, Repositories) um Außenstehenden zu helfen, sich in deinem Projekt zurecht zu finden.

#### 3rd-Party Frameworks
Verwendest du Frameworks, die nicht von dir stammen? Bspw. Swift Packages für Firebase, fertige SwiftUI-Views o.Ä.? Gib diese hier an.

## Ausblick

### Geplante zukünftige Erweiterungen

- [ ] **Community-Features:** Forum oder Chatgruppen zum Austausch zwischen Auswanderern.
- [ ] **Interaktiver Budgetplaner:** Detailliertes Tool zur Finanzplanung.
- [ ] **Verzeichnisse:** Listen mit geprüften Kontakten (Ärzte, Anwälte, Makler, Übersetzer etc.).
- [ ] **Erweiterte Inhalte:** Detailliertere Infos zu "Arbeiten als Angestellter", Firmengründung, Steuern etc.
- [ ] **Zusätzliche Tools:** Basis-Vokabeltrainer (Griechisch), "Fakten über Zypern".
- [ ] **Weitere Länder:** Ausweitung der Inhalte auf andere beliebte Auswanderungsziele.
- [ ] **Erweiterte Nutzerprofile & Anbieter-Plattform:** Möglichkeit für erfahrene Expats, Dienste anzubieten.

## Autor

**Dominik Baki**, Student am **Syntax Institut** im Kurs Fachkraft für App-Entwicklung (iOS & Android).
