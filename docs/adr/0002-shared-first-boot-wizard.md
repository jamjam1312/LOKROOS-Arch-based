# ADR 0002: Gemeinsamer Ersteinrichtungs-Assistent (mobile-first, später Desktop)

- **Status:** Vorschlag (nicht entschieden). Datum: 2026-10-16.
- **Betrifft:** F30 (Mobile-Version), Desktop-Welcome (`lokro-welcome`).

## Problem
Mobile braucht einen Ersteinrichtungs-Assistenten (Sprache, WLAN, SIM-PIN, Stores, BYOK),
der Desktop hat ein Dashboard-Welcome ohne Schrittführung. Zwei getrennte Implementierungen
würden doppelte Pflege und divergierende UX-Prinzipien (Zustimmung, Überspringbarkeit) erzeugen.

## Anforderungen
- Schritt-für-Schritt, jeder Schritt überspringbar, keine Zwangs-Downloads (Prinzip wie 9.9.2/9.9.4).
- Wiederverwendbare QML-Komponenten (Schritt-Container, Zustimmungs-Dialog, Fortschritt).
- Calamares bleibt Installer; der Assistent kümmert sich um den ersten Login — keine Zuständigkeits-Mischung.
- Mobil zuerst (Greenfield, keine Altlast), Desktop-Welcome übernimmt das Pattern später.

## Alternativen
1. **Gemeinsame Komponentenbibliothek (empfohlen):** Ein Schritt-Framework, mobil zuerst produktiv,
   Desktop-Welcome adoptiert schrittweise. Nachteil: Abstraktionsaufwand vor dem ersten Nutzen; API muss stabil bleiben.
2. **Getrennte Assistenten:** Schneller am Anfang, doppelte Pflege und divergierende UX für immer.
3. **Calamares erweitern:** Falsche Zuständigkeit (Installer ≠ erster Login); verworfen.

## Entscheidung (Vorschlag)
Variante 1. Der Assistent lebt als eigene QML-Modulablage (z. B. `lokro-wizard`), mobil zuerst,
Desktop später. Jeder Schritt dokumentiert seine Datenflüsse (was wird wann wohin gesendet — Standard: nichts ohne Zustimmung).

## Begründung
Die Mobile-Arbeit zahlt direkt aufs Desktop-Konto ein statt zwei Welten zu bauen; die
Zustimmungs-Prinzipien (kein Drängen, kein Hintergrund-Download) werden an einer Stelle implementiert und getestet.

## Nachteile
- Upfront-Designaufwand, bevor ein Gerät etwas anzeigt.
- Risiko von Überabstraktion, wenn Desktop-Anforderungen zu früh einfließen — Gegenmittel: mobil zuerst, Desktop-API erst bei Bedarf.

## Auswirkungen
- F30-Einrichtungs-Assistent wird Referenzimplementierung; Desktop-Welcome bekommt Migrations-Task (P3).
- Neue Wizard-Schritte brauchen Design-Review (Zustimmung/Texte), keine stillen Zusatz-Downloads.
