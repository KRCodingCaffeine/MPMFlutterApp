import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AboutViewPage extends StatelessWidget {
  const AboutViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    String htmlContent = """
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: #f4f4f4;
            padding: 10px;
        }
        h2, h3 {
            color: black;
            margin-top: 20px;
        }
        h2 {
            font-size: 1.4rem;
        }
        h3 {
            font-size: 1.2rem;
        }
        p {
            font-size: 1rem;
            color: #333;
        }
        ul {
            padding-left: 20px;
        }
        li {
            font-size: 0.95rem;
            margin: 8px 0;
            list-style-type: none;
            position: relative;
            padding-left: 20px;
            textAlign: TextAlign.justify,
        }
        li::before {
            content: "•";
            position: absolute;
            left: 0;
            color: #2c3e50;
            font-size: 1.2rem;
        }
    </style>

    <h2>ORGANISATION AT A GLANCE</h2>
    <div style="margin-left: 20px;">
      <p>A Socio-Charitable Trust/Organisation established 61 years ago in the city of Mumbai.</p>
      <p>Represents more than 4,000 Maheshwari families residing in Mumbai.</p>
      <p>The Mandal family has a current strength of more than 7,500 members.</p>
    </div>

    <h3>Active Members</h3>
    <ul>
      <li>650 active members, including 250 Ladies and 150 Youth.</li>
      <li>Various committees include:
        <ul>
          <li>Board of Trustees</li>
          <li>Managing Committee</li>
          <li>8 Central Samitis</li>
          <li>8 Regional Samitis</li>
          <li>8 Regional Ladies Samitis</li>
          <li>8 Regional Yuva Samitis</li>
          <li>5 Bhavan Management Samitis</li>
          <li>Medical Assistance Fund, etc.</li>
        </ul>
      </li>
    </ul>

    <h3>Facilities</h3>
    <ul>
      <li>Maheshwari Bhavan at Girgaum provides concessional accommodation for medical visitors.</li>
      <li>A 5-storey Bhavan (40,000 sq. ft.) at Andheri Link Road for events.</li>
      <li>An open plot (36,000 sq. ft.) at Borivali for social events.</li>
    </ul>

    <h3>Social Welfare</h3>
    <ul>
      <li>Financial assistance through "Radha Krishna Lahoti Smriti Kosh" and "Chikitsa Sahayata Kosh".</li>
      <li>Relief support for natural calamities (droughts, earthquakes, floods).</li>
      <li>Loans for education and financial aid through "Videsh Shiksha Kosh".</li>
      <li>Full student sponsorship via "Student Adoption Scheme".</li>
    </ul>

    <h3>Communication</h3>
    <div style="margin-left: 20px;">
      <p>We connect with 7,500+ members through our monthly magazine – <b>"Saraswani"</b>.</p>
    </div>
    """;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: HtmlWidget(
          htmlContent,
          textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
