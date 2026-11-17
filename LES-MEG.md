# Rørkassa – iPhone-app, bare med iPhonen

Appen viser rorkassa.net inne i en ekte iPhone-app. Alt du laster opp til Netlify,
kommer automatisk i appen. Codemagic bygger appen på en Mac i skyen, så du trenger
ikke egen Mac.

Gjør stegene i rekkefølge. Alt gjøres i Safari på iPhonen. Skriv navn og ID-er
**nøyaktig** som her.

## A. Apple – developer.apple.com

1. **Registrer app-ID-en.** Account → Certificates, IDs & Profiles → Identifiers → **+**
   → App IDs → App.
   - Description: `Rorkassa` (uten ø)
   - Bundle ID: velg Explicit og skriv `no.rorkassa.app`
   - Continue → Register.

## B. App Store Connect – appstoreconnect.apple.com

2. **Lag appen.** Apper → **+** → Ny app.
   - Plattform: iOS. Navn: `Rørkassa`. Språk: Norsk (bokmål).
   - Pakke-ID: `no.rorkassa.app`. SKU: `rorkassa`.
3. **Lag API-nøkkel til Codemagic.** Brukere og tilgang → Integrasjoner →
   App Store Connect API → Team-nøkler → **+**.
   - Navn: `Codemagic`. Tilgang: **App Manager**. Trykk Generer.
   - Skriv ned **Issuer ID** og **Key ID**.
   - Last ned nøkkelen (.p8-fila). **Den kan bare lastes ned én gang.** Den havner i Filer-appen.

## C. GitHub – github.com

4. Lag en gratis konto. Trykk **+** → New repository.
   - Navn: `rorkassa-app`. Velg **Private**. Create repository.
5. Pakk ut zip-fila i Filer-appen (trykk på den). På GitHub: trykk
   **uploading an existing file**, velg **alle filene** i mappa Rorkassa-app, og trykk
   **Commit changes**.

## D. Codemagic – codemagic.io

6. Koble til **GitHub** og legg til appen `rorkassa-app`. Spør den om type app,
   velg **Ionic Capacitor App** (eller Other).
7. **Legg inn API-nøkkelen.** Settings → Integrations → **Developer Portal** → Manage keys
   → Add key.
   - Navn: `Rorkassa` (nøyaktig dette navnet)
   - Fyll inn Issuer ID og Key ID, og velg .p8-fila. Save.
8. **Lag sertifikat.** Settings → codemagic.yaml settings → **Code signing identities**
   → iOS certificates → **Generate certificate**.
   - Reference name: `Rorkassa`. Type: **Apple Distribution**. Nøkkel: Rorkassa. Create.

## E. Profil – developer.apple.com igjen

9. Certificates, IDs & Profiles → Profiles → **+** → **App Store Connect** (under Distribution).
   - App ID: `no.rorkassa.app`. Sertifikat: det nye (laget i dag).
   - Navn: `Rorkassa App Store`. Generate.
10. Tilbake i Codemagic: Code signing identities → **iOS provisioning profiles** →
    **Fetch profiles** → velg `Rorkassa App Store` → legg den til.

## F. Bygg

11. Codemagic → appen `rorkassa-app` → **Start new build** → velg
    **Rørkassa iPhone** → Start. Det tar rundt et kvarter.
12. Når den er ferdig, kommer appen i **TestFlight** (last ned TestFlight-appen fra App Store).
    Test den på iPhonen.
13. I App Store Connect: fyll inn beskrivelse, skjermbilder, personvernerklæring og
    Personvern for appen, velg bygget og trykk **Legg til for gjennomgang**.

**Feiler bygget?** Trykk på steget med rødt kryss i Codemagic, ta skjermbilde av
feilmeldingen og send det til Claude.

## Ny versjon av appen senere

Bare nødvendig når selve appen endres (ikon, navn, tillatelser), ikke når nettsiden endres.
Start et nytt bygg i Codemagic. Byggnummeret øker av seg selv. Vil du endre versjonsnummeret
(1.0.0 → 1.0.1 eller 1.1.0), si fra til Claude.

## Har du likevel en Mac?

```
npm install
npm run ios:lag
npm run ios:apne
```

Da åpner Xcode seg, og du kan bygge og laste opp derfra.
