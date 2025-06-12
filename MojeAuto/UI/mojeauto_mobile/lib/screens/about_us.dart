import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF181A1C);
    const textColor = Colors.white70;
    const headingColor = Colors.white;
    const accentColor = Color(0xFF7D5EFF);
    const cardColor = Color(0xFF2A2D31);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: const Text(
          "O nama",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Dobrodošli u MojeAuto",
                    style: TextStyle(
                      color: headingColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "MojeAuto je moderna online platforma za naručivanje auto dijelova. "
                    "Naša misija je omogućiti korisnicima brz, jednostavan i siguran pristup "
                    "kvalitetnim dijelovima za veliki broj vozila.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Šta nas izdvaja?",
                    style: TextStyle(
                      color: headingColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "• Ogroman izbor auto dijelova\n"
                    "• Veliki broj kompatibilnih modela\n"
                    "• Brza i pouzdana dostava\n"
                    "• Pregledne kategorije i proizvođači\n"
                    "• Kvalitet i provjereni brendovi\n"
                    "• Jednostavno naručivanje bez komplikacija",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Zašto MojeAuto?",
                    style: TextStyle(
                      color: headingColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Zato što znamo koliko vam je važno da brzo i lako pronađete "
                    "pravi dio za vaše vozilo. Uz detaljne opise, pregledne kompatibilnosti "
                    "i korisničku podršku, kupovina kod nas je bez stresa.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Pridružite se hiljadama zadovoljnih korisnika i otkrijte koliko može "
                    "biti jednostavno održavati vaše vozilo. Vaše povjerenje je naš najveći uspjeh.",
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Hvala vam što ste odabrali MojeAuto. Nastavljamo da unapređujemo našu platformu "
                "i proširujemo ponudu, kako bismo vam uvijek pružili ono najbolje.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
