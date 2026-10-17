# ADR 0001: Mobile-Shell — Plasma Mobile als Leitkandidat

- **Status:** Vorschlag (nicht entschieden). Datum: 2026-10-16.
- **Betrifft:** F30 (Mobile-Version), F28 (ARM-Port).

## Problem
Die Mobile-Version braucht eine Touch-Shell (Gesten, Maliit-Tastatur, Anruf/SMS-UI, Quick-Settings).
Zur Auswahl stehen Plasma Mobile, Phosh oder eine eigene Shell. Eine Bauchentscheidung würde den
gesamten Illustack (Toolkit, Theming, Einstellungen, Apps) für Jahre festlegen.

## Anforderungen
- Qt- oder GTK-Kontinuität zum bestehenden Desktop-Stack (Plasma 6, Kirigami, KWin).
- Maliit-Tastatur mit eigenem LOKRO-Layout integrierbar.
- Gesten-Ebene, Lockscreen mit PIN + Notruf, `feedbackd`-Haptik machbar.
- Anruf-/SMS-UI entweder nativ oder als Fremd-App einbettbar.

## Alternativen
1. **Plasma Mobile (empfohlen als Leitkandidat):** Gleicher Stack wie Desktop (Qt/Kirigami/KWin);
   bestehende QML-Kompetenz und Widgets wiederverwendbar; ein Theming; Maliit nativ.
   Nachteil: Reifegrad je Gerät unterschiedlich; GNOME-Telefonie-Apps (Calls/Chatty) ggf. ausgereifter.
2. **Phosh (Fallback):** Ausgereifte Telefonie-UX, aber zweiter Toolkit-Stack (GTK) mit eigenem Theming,
   eigenen Einstellungen und doppelter Pflege. Nur falls Plasma Mobile an einem Showstopper scheitert.
3. **Eigene Shell (verworfen):** Vollkontrolle, aber unrealistischer Aufwand für ein Alpha-Projekt.

## Entscheidung (Vorschlag)
Plasma Mobile als Default evaluieren; Phosh nur bei dokumentiertem Showstopper.
Ausstiegskriterien (jeweils mit Nachweis): Maliit-Integration scheitert / Modem-UI nicht abbildbar /
Referenzgerät läuft mit Phosh nachweislich stabiler (Boot, Calls, SMS, Strom).

## Begründung
Stack-Kontinuität schlägt Einzel-App-Vorteile: Ein Toolkit, ein Theming, eine Einstellungs-Welt,
wiederverwendbare Kirigami-Komponenten aus `lokro-shell`. Der Mehraufwand eines Zweit-Stacks wäre
die teuerste Langzeit-Entscheidung im Mobile-Projekt.

## Nachteile
- Plasma Mobile ist je Gerät unterschiedlich reif; Geräteauswahl wird dadurch eingeschränkt.
- Falls GNOME-Apps (Calls/Chatty) nötig werden, braucht es GTK-Brücken (Theming-Bruch möglich).

## Auswirkungen
- F30-Planung läuft auf Qt/Kirigami-Basis; Referenzgeräte-Auswahl bevorzugt Plasma-Mobile-taugliche Ports.
- Bei Showstopper: Re-Evaluation mit Messprotokoll, kein stiller Wechsel.
