import 'resume_data.dart';

class ResumePreset {
  final String id;
  final String title;
  final String titleEn;
  final String icon;
  final String defaultJobTitle;
  final String summary;
  final List<String> skills;
  final List<String> certifications;
  final List<WorkExperience> experiences;
  final String colorHex;

  const ResumePreset({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.icon,
    required this.defaultJobTitle,
    required this.summary,
    required this.skills,
    required this.certifications,
    required this.experiences,
    required this.colorHex,
  });
}

class ResumePresets {
  static const List<ResumePreset> presets = [
    // 1. HOSPITALITY & BARISTA
    ResumePreset(
      id: 'hospitality',
      title: 'Hostelería & Barista',
      titleEn: 'Hospitality & Barista',
      icon: '☕',
      defaultJobTitle: 'Experienced Barista & Hospitality All-Rounder',
      summary:
          'Enthusiastic and fast-paced hospitality professional with over 3 years of hands-on experience in high-volume café and bar environments. Skilled in commercial espresso extraction, latte art, cocktail preparation, and customer-focused service. Holding active Australian RSA and Food Safety certifications. Punctual, energetic, and committed to delivering exceptional dining experiences while maintaining speed and hygiene standards.',
      skills: [
        'Specialty Coffee & Latte Art (200+ cups/shift)',
        'Commercial Machine Operation (La Marzocco, Sanremo)',
        'Cocktail & Wine Service (RSA Compliant)',
        'POS Systems (Square, Lightspeed, OrderMate)',
        'High-Volume Table Service & Fast Ticket Dispatch',
        'Stock Rotation & Strict Food Hygiene Compliance',
        'Multi-lingual Customer Service & Upselling',
      ],
      certifications: [
        'RSA (Responsible Service of Alcohol) - Valid & Active',
        'Barista Mastery Level 1 & 2 (Espresso Extraction & Latte Art)',
        'Food Safety & Handling Certificate',
        'Australian / International Driver\'s Licence (Class C)',
      ],
      experiences: [
        WorkExperience(
          role: 'Head Barista & Café All-Rounder',
          company: 'The Daily Grind Café',
          location: 'Sydney, NSW',
          period: '2024 - Present',
          bulletPoints: [
            'Operated 3-group La Marzocco machine during peak breakfast rushes, producing 200+ specialty coffees daily with consistent milk texture.',
            'Calibrated grinders and dialed in espresso extraction every morning to maintain high cup quality and reduce wastage by 15%.',
            'Managed cash register and EFTPOS point-of-sale transactions with 100% daily till accuracy and warm customer hospitality.',
          ],
        ),
        WorkExperience(
          role: 'Food & Beverage Attendant / Bartender',
          company: 'Harbourview Bistro & Bar',
          location: 'Melbourne, VIC',
          period: '2023 - 2024',
          bulletPoints: [
            'Delivered attentive table service for 80+ seat dining room, taking orders, carrying 3-plate passes, and making beverage recommendations.',
            'Enforced strict RSA compliance while pouring craft beers, spirits, and classic cocktails during busy weekend evening shifts.',
            'Collaborated with kitchen pass for rapid food running and sanitised section stations in accordance with local hygiene guidelines.',
          ],
        ),
      ],
      colorHex: '#D96B43', // Ayers Rock Terracotta
    ),

    // 2. CONSTRUCTION & LABOURING
    ResumePreset(
      id: 'construction',
      title: 'Construcción & Obras',
      titleEn: 'Construction & Labouring',
      icon: '🦺',
      defaultJobTitle: 'General Labourer & Trades Assistant',
      summary:
          'Physically fit, hardworking, and safety-conscious Labourer with proven experience on residential and commercial building sites. Fully compliant with SafeWork Australia standards, holding a valid White Card and full PPE (steel-cap boots, hi-vis, hard hat). Reliable, proactive, and accustomed to early 6:00 AM starts in demanding weather conditions. Strong team player eager to support carpenters, bricklayers, and site supervisors.',
      skills: [
        'Safe Manual Handling (Capable of 25kg+ Lifting)',
        'Site Housekeeping, Waste Sorting & Demolition Assistance',
        'Power & Hand Tools (Jackhammers, Grinders, Hammer Drills)',
        'Workplace Health & Safety (WHS) & SafeWork Compliance',
        'Material Unloading, Staging & Scaffolding Support',
        'Concrete Mixing, Pouring & Wheelbarrow Operation',
        'Reliable 6:00 AM Punctuality & Physical Endurance',
      ],
      certifications: [
        'General Construction Induction (White Card CPCCWHS1001)',
        'Full Personal Protective Equipment (PPE) Equipped',
        'First Aid & CPR (HLTAID011)',
        'Valid Manual Driver\'s Licence & Reliable Transport',
      ],
      experiences: [
        WorkExperience(
          role: 'Construction Labourer & Trade Assistant',
          company: 'Apex Build Solutions',
          location: 'Brisbane, QLD',
          period: '2024 - Present',
          bulletPoints: [
            'Assisted licensed carpenters and site supervisors with structural framing, timber hauling, and site preparation across multi-level developments.',
            'Safely operated demolition hammers, industrial angle grinders, and vacuum extractors with zero lost-time injury incidents.',
            'Conducted daily site sweeps, hazard reporting, and waste disposal in strict accordance with SafeWork Australia WHS guidelines.',
          ],
        ),
        WorkExperience(
          role: 'Civil & Landscaping Labourer',
          company: 'Greenfield Earthworks',
          location: 'Gold Coast, QLD',
          period: '2023 - 2024',
          bulletPoints: [
            'Executed manual trench excavation, paving preparation, turf laying, and retaining wall construction in outdoor summer conditions.',
            'Unloaded over 10 tonnes of aggregate, timber, and cement each week and safely operated utility trailers.',
          ],
        ),
      ],
      colorHex: '#1E293B', // Executive Charcoal Navy
    ),

    // 3. FARM & HARVEST (88 DAYS REGIONAL WORK)
    ResumePreset(
      id: 'farm',
      title: 'Granja & 88 Días',
      titleEn: 'Farm & Harvest (88 Days)',
      icon: '🚜',
      defaultJobTitle: 'Farm Hand & Harvest Worker (88-Day Eligible)',
      summary:
          'Energetic, dependable farm hand experienced in fast-paced agricultural and harvest operations in regional Australia. Proven ability to meet and exceed piece-rate picking targets while protecting plant and fruit quality. Accustomed to physical outdoor labour, early dawn starts, and extreme regional climates. Looking for specified regional work with immediate availability and 6-month commitment.',
      skills: [
        'High-Speed Fruit Picking & Packing Shed Grading',
        'Tractor & Farm Machinery Pre-Operational Checks',
        'Irrigation Line Maintenance, Pruning & Weed Management',
        'High Physical Stamina in Hot Regional Weather (35°C+)',
        'Strict Bio-Security & Chemical Safety Protocol Compliance',
        'Form 1263 Specified Work Documentation Familiarity',
      ],
      certifications: [
        'Chemical Handling & Agricultural Safety Induction',
        'Valid Driver\'s Licence (Own 4WD Vehicle with Camp Setup)',
        'Remote Area First Aid & CPR',
      ],
      experiences: [
        WorkExperience(
          role: 'Harvest Worker & Orchard Picker',
          company: 'SunState Citrus Orchards',
          location: 'Bundaberg, QLD',
          period: '2024 - 2025',
          bulletPoints: [
            'Harvested high daily quotas of mandarins and lemons with meticulous branch care to achieve premium export grading.',
            'Graded, sorted, and packed produce in high-velocity packing sheds at an average rate of 160 cartons per hour.',
            'Maintained accurate timesheets and employer payslips for official Form 1263 Working Holiday Visa sign-off.',
          ],
        ),
        WorkExperience(
          role: 'Farm Labourer & Field Assistant',
          company: 'Valley Fresh Produce',
          location: 'Shepparton, VIC',
          period: '2023 - 2024',
          bulletPoints: [
            'Conducted seasonal pruning, thinning, and weed control across 50 hectares of stone fruit orchards.',
            'Assisted irrigation technicians with pipeline repairs and drip-feed checks during high-temperature spells.',
          ],
        ),
      ],
      colorHex: '#00A896', // Coastal Emerald Green
    ),

    // 4. RETAIL & SALES
    ResumePreset(
      id: 'retail',
      title: 'Retail & Tiendas',
      titleEn: 'Retail & Customer Service',
      icon: '🛍️',
      defaultJobTitle: 'Retail Sales Associate & Cashier',
      summary:
          'Vibrant, customer-oriented Retail Associate with extensive background in boutique apparel, grocery, and consumer goods. Proven talent in engaging shoppers, driving upselling, and executing flawless EFTPOS and point-of-sale reconciliations. Fluent English speaker with high empathy, energetic presence, and rapid ability to master inventory and visual merchandising guidelines.',
      skills: [
        'POS Cash Handling & EFTPOS Till Reconciliation',
        'Visual Merchandising & Store Display Maintenance',
        'Customer Needs Discovery & Active Upselling',
        'Inventory Audits, Stock Replenishment & Barcode Scanning',
        'Conflict Resolution & Australian Consumer Law Returns',
        'Bilingual English & Spanish Customer Communication',
      ],
      certifications: [
        'Retail Customer Service Excellence Certificate',
        'Food Safety & Hygiene Fundamentals',
        'First Aid & Emergency Response',
      ],
      experiences: [
        WorkExperience(
          role: 'Retail Sales Associate',
          company: 'Pacific Surf & Lifestyle Co.',
          location: 'Byron Bay, NSW',
          period: '2024 - Present',
          bulletPoints: [
            'Greeted and consulted up to 250+ customers daily, providing styling advice and promoting accessories to increase basket size by 18%.',
            'Processed over \$6,000 in daily transactions with zero discrepancies across cash registers and digital payment terminals.',
            'Replenished stock on sales floor and maintained impeccable store presentation adhering to visual merchandising guidelines.',
          ],
        ),
        WorkExperience(
          role: 'Customer Service & Stock Assistant',
          company: 'Metro Fresh Markets',
          location: 'Sydney, NSW',
          period: '2023 - 2024',
          bulletPoints: [
            'Managed high-traffic front-end checkouts during evening peak hours with fast, cheerful customer interactions.',
            'Conducted stock intake verification against delivery invoices and rotated perishable stock according to FIFO standards.',
          ],
        ),
      ],
      colorHex: '#D96B43',
    ),

    // 5. CLEANING & HOUSEKEEPING
    ResumePreset(
      id: 'cleaning',
      title: 'Limpieza & Hoteles',
      titleEn: 'Cleaning & Housekeeping',
      icon: '🧹',
      defaultJobTitle: 'Housekeeping Specialist & Commercial Cleaner',
      summary:
          'Diligent and efficient cleaning professional with expertise in high-turnover luxury hotels, holiday resorts, and commercial office premises. Meticulous eye for hygiene detail, rapid room turnaround speed, and thorough knowledge of chemical safety (COSHH / WHS). Self-reliant, trustworthy, and committed to meeting 5-star brand standards.',
      skills: [
        'Luxury Hotel Room Turnaround (15-18 rooms/day)',
        'Sanitisation, Disinfection & Chemical Handling Safety',
        'Linen Inventory Management & High-Pressure Washing',
        'Attention to Detail & Preventive Deep-Cleaning Methods',
        'Self-Directed, Trustworthy, Discrete & Punctual',
      ],
      certifications: [
        'Hotel Housekeeping & Hospitality Standards Certificate',
        'National Police Clearance Check (Australia)',
        'Safe Chemical Handling & WHS Induction',
      ],
      experiences: [
        WorkExperience(
          role: 'Hotel Housekeeper & Room Attendant',
          company: 'Oceanside Resort & Suites',
          location: 'Cairns, QLD',
          period: '2024 - Present',
          bulletPoints: [
            'Cleaned, stripped, and prepared 16 guest rooms daily according to 5-star resort inspection scorecards.',
            'Safely operated commercial carpet extractors, steam mops, and floor polishers with complete PPE compliance.',
            'Reported maintenance defects promptly via mobile hotel software, maintaining a 98% room readiness rating.',
          ],
        ),
        WorkExperience(
          role: 'Commercial Office Cleaner',
          company: 'Spotless Commercial Services',
          location: 'Perth, WA',
          period: '2023 - 2024',
          bulletPoints: [
            'Performed after-hours sanitisation of corporate workstations, kitchens, and restrooms across 3 office levels.',
            'Managed chemical dilutions safely and secured office perimeter and alarms upon shift completion.',
          ],
        ),
      ],
      colorHex: '#00A896',
    ),

    // 6. CORPORATE & OFFICE ADMIN
    ResumePreset(
      id: 'office',
      title: 'Oficina & Admin',
      titleEn: 'Office & Administration',
      icon: '💼',
      defaultJobTitle: 'Administrative Assistant & Front Desk Coordinator',
      summary:
          'Organised and articulate administrative professional with exceptional communication skills and mastery of modern office productivity suites. Experienced in front-desk reception, executive calendar scheduling, accurate data entry, and multi-line phone management. Highly adaptable, proactive problem solver ready to assist fast-paced corporate teams in Australia.',
      skills: [
        'Front Office Reception & Multi-Line Switchboard Management',
        'Microsoft 365 (Advanced Excel, Word) & Google Workspace',
        'CRM Data Entry & Database Hygiene (Salesforce, HubSpot)',
        'Invoice Matching, Expense Tracking & Basic Bookkeeping',
        'Travel Coordination & Meeting Scheduling',
        'Bilingual Professional Correspondence (English & Spanish)',
      ],
      certifications: [
        'Certificate IV in Business Administration / Equivalent',
        'High Typing Speed (65+ WPM, 99% Accuracy)',
        'First Aid & Workplace Safety Warden',
      ],
      experiences: [
        WorkExperience(
          role: 'Administrative Assistant & Receptionist',
          company: 'Nexus Business Solutions',
          location: 'Sydney CBD, NSW',
          period: '2024 - Present',
          bulletPoints: [
            'Managed front-desk reception, welcoming corporate visitors and directing over 60 inbound calls daily with polished professionalism.',
            'Entered vendor invoices and matched purchase orders into accounting database, reducing processing backlogs by 25%.',
            'Organised board meetings, catered client lunches, and maintained office inventory and stationery supplies.',
          ],
        ),
        WorkExperience(
          role: 'Data Entry & Customer Support Specialist',
          company: 'Alpha Global Logistics',
          location: 'Melbourne, VIC',
          period: '2023 - 2024',
          bulletPoints: [
            'Processed over 120 consignment bookings daily with high accuracy and reconciled shipping manifests.',
            'Handled customer email queries, tracking updates, and escalated delivery requests promptly.',
          ],
        ),
      ],
      colorHex: '#1E293B',
    ),
  ];

  static ResumePreset getById(String id) {
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets.first,
    );
  }
}
