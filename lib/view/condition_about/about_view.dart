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
            textAlign: TextAlign.justify;
        }
        li::before {
            content: "•";
            position: absolute;
            left: 0;
            color: #2c3e50;
            font-size: 1.2rem;
        }
        .section {
            margin-bottom: 25px;
        }
        .vision-intro {
            font-style: italic;
            margin-bottom: 15px;
        }
        .origin-image {
            width: 100%;
            max-width: 400px;
            margin: 15px auto;
            display: block;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .legend {
            font-style: italic;
            color: #555;
            text-align: center;
            margin-top: 5px;
        }
    </style>

    <div class="section">
      <h2>ORGANISATION AT A GLANCE</h2>
      <ul>
        <li>A Socio Charitable Trust/Organisation established 67 years ago in the city of Mumbai.</li>
        <li>This is the only social organisation representing more than 4,500 Maheshwari families residing in the Metropolis city of Mumbai.</li>
        <li>The Mandal family has a current strength of more than 8,500 active life members.</li>
        <li>800 active members including 275 Ladies and 175 Youth are active Karyakarta carrying out Mandal's activities under:
          <ul>
            <li>Board of Trustees</li>
            <li>Managing Committee</li>
            <li>8 Central Samitis</li>
            <li>8 Regional Samitis</li>
            <li>8 Regional Mahila Samitis</li>
            <li>8 Regional Yuva Samitis</li>
            <li>8 Varishth Nagrik Upsamitis</li>
            <li>5 Bhavan Management Samitis</li>
            <li>Chikitsa Sahayata Kosh</li>
          </ul>
        </li>
        <li>Places utmost importance on the Unity of the organisation and functions based on democratic principles, by taking all members together.</li>
        <li>Nearly 200 programmes are organised every year by various samitis.</li>
        <li>Equipped with all modern amenities, Maheshwari Bhavan at Girgaum mainly provides accommodation at concessional rate to outstation Samaj Bandhus coming for medical treatment.</li>
        <li>A huge 5 storeys Bhavan admeasuring 40,000 square feet is available at Andheri, Link Road for organising weddings, spiritual discourses & other auspicious events by Samaj Bandhus.</li>
        <li>Open Plot admeasuring 36,000 square ft. is available at Borivali for members to organise various social events.</li>
        <li>Provides assistance to under privileged Members for their sustenance through 'Radha Krishna Lahoti Smriti Kosh'.</li>
        <li>Provides financial assistance for medical purposes to under privileged members through Chikitsa Sahayata Kosh.</li>
        <li>Provides assistance to people affected by natural calamities such as drought, earthquake, floods, etc.</li>
        <li>Collects Donations from Members every year and distributes the same as loan to students for educational purposes.</li>
        <li>Provides financial assistance through Videsh Shiksha Kosh to students going abroad for higher studies.</li>
        <li>Fully sponsoring students' education under 'Students Adoption Scheme'.</li>
        <li>Distributes Note Books at concessional rates to school and college students every year.</li>
        <li>Organises Members get together, Cultural Programme and felicitates bright students with gold and silver medals every year at Annual Day Celebration.</li>
        <li>Distributes every year pure Saatu Churna and other products at cost price, on the occasion of Badi Teej Festival.</li>
        <li>Operates Homeopathy clinics at Ghatkopar, Andheri & Girgaum, Physiotherapy centres at Andheri, Borivali and Ghatkopar and has installed water coolers at Goregaon and Borivali as General Welfare Schemes.</li>
        <li>Provides financial assistance in Tribal areas to children for educational and medical purposes and distributes products useful in schools.</li>
        <li>Communicates with more than 8,500 Members through Mandal's monthly magazine - 'Saraswani'.</li>
      </ul>
    </div>

    <div class="section">
      <h2>OUR VISION</h2>
      <p class="vision-intro">Maheshwari Samaj is in the forefront of the country's various organised and progressive Societies. It occupies a unique position amongst the nation's other Societies due to its vast and multifarious specialities / qualities. The salient features of Mandal's Vision about Maheshwari Samaj in the 21st Century are as follows:</p>
      
      <h4>1. Social Completeness</h4>
      <p>The Samaj to protect and preserve its traditional culture, values, faith and dignity while adopting need-based changes to continue to march forward towards social completeness.</p>
      
      <h4>2. Family Co-ordination</h4>
      <p>The Samaj to have family happiness, love, respect and trust for each other and to be a part of each other's happiness and sorrows. Also, to have an inspirational environment all-around, particularly to make life of Senior (Aged) Members of the family happy and peaceful.</p>
      
      <h4>3. Health</h4>
      <p>The Samaj to follow the time-tested belief that 'prevention is better than cure' and undertake purification of mind, body & soul by practising Yoga, Exercise, Follow rules of Nature and have Pure and Nutritious diets as also regular Health check-ups.</p>
      
      <h4>4. Education</h4>
      <p>There should be an environment of encouraging individual capability and expanding capacity in the Samaj so that every child - male or female – gets the best education according to his/her potentials, to suit the needs of changing scenario.</p>
      
      <h4>5. Traditional Values</h4>
      <p>The Samaj to follow/inculcate traditional human values, time-tested social traditions and culture-oriented "Teej" and other festivities so that it continues to remain least affected by the wide-spread distortions and disturbing trends all around.</p>
      
      <h4>6. Youth and Females</h4>
      <p>The Samaj to have a wide-spread participation of Youth and Ladies in the Social activities so that it can protect and preserve its traditional values, customs, faith and dignity, etc.</p>
      
      <h4>7. Depleting Population</h4>
      <p>Depleting population has, of late, surfaced as an issue of concern in the Samaj. Bearing this in mind, each household to actively observe its family planning appropriately, so that Maheshwari Samaj continues to be unique eternally for the cause of not only national service but also for the service of the humanity at large.</p>
      
      <h4>8. Economic</h4>
      <p>Economic activities are at the root of KARMA of Maheshwari Samaj. Therefore, in the World of Commerce, even in the changing scenario, the Samaj to continue to observe pious principles and work ethics so that it can achieve all-round success in the Economic World and be prosperous.</p>
      
      <h4>9. Abolition of Superstitions</h4>
      <p>The Samaj to become free of superstitions and be rational. The abolition of superstitions and rational behaviour will enable it to face the challenges of generation gap as well.</p>
      
      <h4>10. Service to the Man-kind</h4>
      <p>The Samaj to become capable, physically and economically, so that it continues to play a leading role in the service of the humanity with appropriate contributions in various ventures of public importance and also in natural calamities.</p>
    </div>

    <div class="section">
      <h2>OUR ACTIVITIES</h2>
      <ul>
        <li>Every year Mandal Organises, under the banner of its committees, about 200 programmes in Greater Mumbai</li>
        <li>Every year meritorious students are honoured at Annual Day Function organized by the Mandal.</li>
        <li>Every Year Mahila Samities organize distribution of "Satu Choorn" at Cost Price at the women's festival of Badi Teej.</li>
        <li>Once in four years a Grand Mega Snehmilan is organized for all members of the Community where about 8000 persons attend and enjoy the events throughout this day.</li>
        <li>Conducting various religious & social functions for Ladies</li>
        <li>Special programs for the benefit of members in the fields of Health & Medical, Eye Checkup Camps, Special tie up with Hospitals for concessionary services for health & other checkup</li>
      </ul>
    </div>

    <div class="section">
      <h4>SERVICES TO SOCIETY/NATION</h4>
      <ul>
        <li>Mandal is alive to the needs of the Country during National Calamities and has made contributions during Latur Earthquake, Gujarat Earthquake, Orissa Cyclone, Kargil War, Kerala & Mumbai Floods, drought in Rajasthan and Marathwada etc.</li>
        <li>Every year Mandal distributes exercise note books to members at subsidized price. Some Samities distribute free Note Books to needy students at Municipal Schools.</li>
        <li>Drinking Water Fountains - Pyau - are operating and managed for common man at Borivali, Girgaon, Ghatkopar</li>
      </ul>
    </div>

    <div class="section">
      <h4>FACILITIES FOR MEMBERS</h4>
      <ul>
        <li>Girgaum Maheshwari Bhavan - Renovated Bhavan caters to the needs for accommodation for persons coming from out of Mumbai for medical treatments. Also has a Hall for social functions.</li>
        <li>"Maheshwari Bhavan" Andheri West - about 40,000 sq. ft. available for use for marriage and social ceremonies etc since 2005</li>
        <li>36,000 sq. ft. Plot available for use at Borivali West.</li>
        <li>Ghatkopar Bhavan Homeopathy Clinic is running for needy patients.</li>
        <li>340 square feet (Carpet) AC Flat with Toilet, on Ground Floor is available in Mahesh Nagar, Goregaon</li>
      </ul>
    </div>
    
    <div class="section">
      <h4>Other</h4>
      <ul>
        <li>Tie-ups with medicine suppliers, hospitals and diagnostic agencies for medical discounts to Members</li>
      </ul>
    </div>

    <div class="section">
      <h4>STUDENT LOAN/SCHOLARSHIP</h4>
      <ul>
        <li>Radhakrishna Lahoti Memorial Fund - Caters to the needy persons for financial assistance for livelihood</li>
        <li>Chikitsa Sahayata Kosh - Caters to the needs of persons who require financial assistance for medical treatment.</li>
        <li>Students Scholarship Samiti - Collection of funds from Community Members and distribution as Loan or Scholarship to needy students of Maharashtra and Rajasthan</li>
        <li>Loan for Students going abroad for higher studies are also given as financial assistance.</li>
        <li>There is a Students Adoption Scheme wherein needy meritorious students are adopted and given full financial help for 3 to 4 years till completion of education.</li>
      </ul>
    </div>

    <div class="section">
      <h4>CONNECT WITH MEMBERS</h4>
      <ul>
        <li>Monthly News Letter "SARASWANI" is published which contains all activities of Mandal.</li>
        <li>Publishes "Janaganana" or "Parivar Parichay Book" covering Maheshwari families of the zone by regional Zonal Committies at regular interval providing complete info about Maheshwari family, contact details & business details.</li>
      </ul>
    </div>
    
    <div class="section">
      <h2>OUR BHAVANS</h2>
      <p>Over the years, Maheshwari Pragati Mandal, Mumbai has set-up Bhavans in different areas of Mumbai for the service of both Mumbai based Members and for Visitors coming from out of Mumbai, at reasonable and affordable costs. Mandal Bhawnas are located at: -</p>
      
      <ul>
        <li>MAHESHWARI PRAGATI MANDAL, GIRGAON, CHAIRABAZAR</li>
        <li>MAHESHWARI BHAVAN, ANDHERI</li>
        <li>BORIVALI PLOT</li>
        <li>GHATKOPAR BHAVAN</li>
        <li>GOREGAON BHAVAN</li>
      </ul>

      <h4>1) MAHESHWARI PRAGATI MANDAL (GIRGAON, CHIRABAZAR)</h4>
      <div class="bhavan-info">
        <p>Equipped with all modern amenities Maheshwari Bhavan situated at Girgaum, mainly provides accommodation at concessional rate to outstation Community members coming to Mumbai for medical treatment or for other purposes.</p>
      </div>

      <h4>2) MAHESHWARI BHAVAN, ANDHERI</h4>
      <div class="bhavan-info">
        <p>A 5 storey Bhavan admeasuring 40,000 square feet at Andheri Link Road is for organising weddings, spiritual discourses, auspicious events of Community Members and their families and friends.</p>
        <p>First Floor & Fourth Floor available only up to 10:30 pm.</p>
        <ul>
          <li>The Bhavan is available for auspicious ceremonies like Wedding, Marriage Anniversary, Birthday Party and other similar occasions.</li>
          <li>Subsidised rates are provided for Spiritual Programmes, Bhagwat Katha, Discourses, Teaching - Training, etc.</li>
          <li>Rules and regulations applicable at the time of use will prevail.</li>
          <li>For additional information, tariff, etc please contact the Manager of Andheri Bhavan.</li>
        </ul>
      </div>

      <h4>3) BORIVALI PLOT</h4>
      <div class="bhavan-info">
        <ul>
          <li>Plot admeasuring 36,000 sq.ft. includes 2 AC Rooms with attached bathrooms</li>
          <li>The Plot is available for auspicious ceremonies like Wedding, Marriage Anniversary, Birthday Party and other similar occasions.</li>
          <li>Booking in advance:
            <ul>
              <li>For members: 12 Months</li>
              <li>For others: 6 months</li>
            </ul>
          </li>
        </ul>
      </div>

      <h4>4) GHATKOPAR BHAVAN INFORMATION</h4>
      <div class="bhavan-info">
        <ul>
          <li>AC Hall - 750 sq.ft.</li>
          <li>AC Room - 180 sq.ft. with attached Bathroom</li>
          <li>Open terrace - 1,300 square feet</li>
          <li>Homeopathy Clinic - 100 square feet</li>
        </ul>
      </div>

      <h4>5) GOREGAON BHAVAN INFORMATION</h4>
      <div class="bhavan-info">
        <ul>
          <li>340 sq.ft. (Carpet) AC Flat with Bathroom, on Ground Floor is available at Mahesh Nagar.</li>
          <li class="contact-info">CONTACT NUMBERS FOR BOOKING: [Please contact the Mandal office for current contact details]</li>
        </ul>
      </div>
    </div>
    <div class="section">
      <h2>ORIGIN OF MAHESHWARIS</h2>
      
      [IMAGE:assets/images/maheshwari_origin.png:Origin of Maheshwaris]
      
      <ul>
        <li>There are several legends about the origin of the Maheshwari community but the one generally accepted places the date of their origin as about 4,000 years prior to the Vikram Samvat.</li>
        <li>Once upon a time there was a king called Khadaksen who ruled Village Khandela (near Jaipur). The kingdom was well administered under the able and efficient administration of King Khadaksen. The people of Khandela loved their King very much & lived in peace and harmony.</li>
        <li>The King had 24 wives. He had everything he wanted except a son who could take over his throne when he grew older. The King worshipped saints and to get their blessings he performed a big Yagya. Being impressed the saints & holymen blessed the king with a son but warned him that the son should not go towards the north side till his age of 16.</li>
        <li>Shortly one beautiful day his 5th wife Queen Champavati gave birth to a beautiful boy. The child was given the name of Sujan Kuvar. The whole kingdom of Khandela celebrated the birth of Rajkumar Sujan Kuvar. He grew up well trained the arts of Administration & Weaponry.</li>
        <li>Some years later young Sujan came in religious touch with the Jain Religion and accepted it completely. He started destroying Hindu temples and building Jain temples in their place.</li>
        <li>One Day while he was on his way for hunting with his 72 Rajput soldiers he came across Sadhus (holymen) at performing Yagya. He ordered his men to destroy the Yagya immediately. The Sadhus were enraged and cursed the King and his Rajput soldiers such that they were all converted into Stones.</li>
        <li>When this news reached the now elderly King Khadaksen, he died of sorrow. The Kingdom lost their its king. 16 queens committed Sati and gave away their life as per the then prevalent tradition.</li>
        <li>Chandravati, the wife of Sujan Kumar along with the wives of the 72 Rajputs went crying to the holy saints and begged them to forgive their husbands. The Saints gave these wives a Akshay Mantra by which they could impress God Shiva & Goddess Parvati. The wives gave up their homes and started staying in caves with the sole goal of chanting the mantra. Finally Lord Shiva & Goddess Parvati were impressed by their devotion & love for their husbands and gave back the lives of Rajkumar Sujan & the 72 Rajputs.</li>
        <li>At once all of them came to life as if they were awakening from a long sleep. Getting their life back all of them went to Lord Shiva and prayed to him to forgive their sin. Lord Shiva asked these men to give up their weapons and violent way of life and begin a new life as Vaishya i.e. businessmen and not Kshatriya. He blessed these men to form a community which would have his eternal blessing - Maheshwari - which when translated means the Boon of Lord Shiva.</li>
        <li>However, the soldiers were hesitant to accept their wives since they still belonged to the Kshatriya caste. At this point Parvati Mata said "All of you take four parikramas around me and whoever are wife and husband their gathbandhan will be joined automatically and they will get married into the Vaishya community". At this everyone did so and they were re-joined as Vaishya husbands and wives. Even today four feras (parikramas) are done outside the wedding Mandap during Maheshwari weddings as a reminder of our origin.</li>
        <li>Lord Shiva gave his blessings to the seventy-two Vaishya couples on the 9th day of Jyesth Shukla Paksh in the 9th year of Yudhisthira Sanvat. On this day newlywed brides and grooms are encouraged to worship Lord Shiva and Mata Parvati puja so that they can be blessed with children and live a happy and joyous life eternally.</li>
        <li>Each of the 72 Rajput couples constituted a separate Khanp and in this way seventy-two Maheshwari khanps or Surnames were created. After this five additional Khanps were also added.</li>
      </ul>
    </div>

    <div class="section">
      <h4>CULTURE AND SPECIAL MAHESHWARI FESTIVALS</h4>      
      <ul>
        <li>As far as religion is concerned the Maheshwaris worship Lord Shiva and Goddess Parvati. Certain special rituals and festivals are observed by them too. A rite which has great significance for the women is called Baditeej. It is celebrated on the third (Krishnapaksha) of Bhadrapada of the Vikram. Samvat year is the time when women fast and pray for the longevity of their husbands and unmarried girls pray for good husbands. Only the men cut peenda after which the women perform puja and break their fast.</li>
        <li>A rite which has great significance for the women is called Baditeej. It is celebrated on the third (Krishnapaksha) of Bhadrapada of the Vikram. Samvat year is the time when women fast and pray for the longevity of their husbands and unmarried girls pray for good husbands. Only the men cut peenda after which the women perform puja and break their fast.</li>
        <li>Gorja or Gavraja is celebrated on the third day of Chaitra (Sudi) when Shiva and Parvati are worshipped. Unmarried girls worship the goddess Gorja with gulla (the inside of green grass) for sixteen days and married women worship her for eight days with doob.</li>
        <li>Maheshwaris celebrate Raksha Bandhan twenty days after the usual date of its celebration on the fifth of the second half of Bhadrapadand. It is known as Bhai Panchami or Rishi Panchami.</li>
        <li>Jaystha Sukla navami of the Samvat year is celebrated as Mahesh Navami to commemorate the birth of the Maheshwari community when Lord Mahesh (another name for Lord Shiva) is worshipped.</li>
      </ul>
    </div>
    """;

    // Process the HTML content to replace image placeholders
    final processedHtml = htmlContent.replaceAllMapped(
      RegExp(r'\[IMAGE:(.*?):(.*?)\]'),
      (match) {
        final path = match.group(1)!;
        final alt = match.group(2)!;
        return '''
        <div style="text-align: center; margin: 15px 0;">
          <img src="$path" alt="$alt" style="max-width: 300px; width: 100%; border-radius: 8px;"/>
          <p style="font-style: italic; color: #555; margin-top: 5px;">$alt</p>
        </div>
        ''';
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'About Us',
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: HtmlWidget(
          processedHtml,
          textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          customWidgetBuilder: (element) {
            if (element.localName == 'img') {
              final src = element.attributes['src'];
              final alt = element.attributes['alt'] ?? '';
              if (src != null) {
                return Column(
                  children: [
                    Image.asset(
                      src,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/maheshwari_festivals.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      alt,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }
            }
            return null;
          },
        ),
      ),
    );
  }
}
