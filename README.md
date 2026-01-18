# HuysuzApp

> **"Kesfet. Coz. Fethet."** - AI Destekli Instagram Profil Analizcisi

Instagram profillerini yapay zeka ile analiz eden, eglenceli kisilik tespitleri ve sohbet baslangici onerileri sunan mobil uygulama.

## Ozellikler

### Temel Ozellikler
- Instagram profil linki veya screenshot ile analiz
- AI destekli "Vibe Type" kisilik analizi
- Kisisellestirilmis sohbet baslangici onerileri (5 adet)
- Red Flags / Green Flags tespiti
- Eglenceli "Roast" yorumlari
- Sonuclari paylasma

### Derin Analiz (Deep Analysis)
- Coklu post analizi
- Profil arketipi belirleme
- Engagement analizi
- Iliski tahmini
- Uyari isaretleri

### Monetizasyon Sistemi
- Free/Premium model
- Gunluk 2 ucretsiz analiz
- Rewarded Ads (+1 kredi)
- Paylasim bonusu (+1 kredi)
- Streak sistemi (3. ve 7. gun bonuslari)
- Premium ile sinirsiz erisim

### Diger
- Turkce / Ingilizce dil destegi
- Tarama gecmisi
- Basarim sistemi
- Karanlik tema

## Teknoloji

| Katman | Teknoloji |
|--------|-----------|
| Mobil | Flutter |
| Backend | Python FastAPI |
| AI | Claude API |
| Auth & DB | Firebase |
| Odeme | RevenueCat |
| Reklam | Google AdMob |
| Analytics | Firebase Analytics |

## Proje Yapisi

```
whisperer/
├── mobile/           # Flutter uygulamasi
│   ├── lib/
│   │   ├── models/       # Veri modelleri
│   │   ├── providers/    # State yonetimi
│   │   ├── screens/      # Ekranlar
│   │   ├── services/     # API servisleri
│   │   ├── widgets/      # UI bileşenleri
│   │   └── theme/        # Tema ve renkler
│   └── android/ios/      # Platform dosyalari
├── backend/          # FastAPI sunucusu
│   └── app/
│       ├── api/          # API endpointleri
│       ├── services/     # Is mantigi
│       └── prompts/      # AI promptlari
└── bridge/           # Gelistirme icin Claude Bridge
```

## Kurulum

### Gereksinimler
- Flutter SDK 3.x
- Python 3.11+
- Firebase projesi
- AdMob hesabi
- RevenueCat hesabi

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env      # API anahtarlarini duzenle
python run.py
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

### APK Olusturma

```bash
cd mobile
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## AdMob Yapilandirmasi

| Reklam Turu | Konum |
|-------------|-------|
| Banner | Ana ekran |
| Interstitial | Sonuc ekrani |
| Rewarded | Kredi kazanma |

## Guvenlik ve Yasal

- Kullanim Sartlari ekrani (ilk acilista)
- Tum paylasimlar disclaimer iceriyor
- "Eglence amacli AI tahmini" uyarisi
- KVKK/GDPR uyumlu veri isleme

## Lisans

MIT License

---

**HuysuzApp** - Profil analizi hic bu kadar eglenceli olmamisti!
