/// Localized translations for the 9 Australian Regional Work industries,
/// Home Affairs official tables, approved roles, exclusions and legal tips.
class IndustryTranslations {
  static String getName(String id, String lang) {
    switch (lang) {
      case 'fr':
        switch (id) {
          case 'tourism_hospitality':
            return 'Tourisme & Hôtellerie-Restauration';
          case 'agriculture':
            return 'Culture Végétale & Élevage';
          case 'construction':
            return 'BTP & Construction';
          case 'fishing':
            return 'Pêche & Perliculture';
          case 'forestry':
            return 'Sylviculture & Exploitation Forestière';
          case 'bushfire_recovery':
            return 'Reconstruction Post-Incendie';
          case 'flood_recovery':
            return 'Secours Inondations & Catastrophes';
          case 'healthcare_covid':
            return 'Santé & Secteur Médical COVID-19';
          case 'mining':
            return 'Mines & Carrières (Sous-classe 417)';
          default:
            return id;
        }
      case 'it':
        switch (id) {
          case 'tourism_hospitality':
            return 'Turismo & Ospitalità';
          case 'agriculture':
            return 'Agricoltura & Allevamento';
          case 'construction':
            return 'Edilizia & Costruzioni';
          case 'fishing':
            return 'Pesca & Coltivazione di Perle';
          case 'forestry':
            return 'Silvicoltura & Abbattimento Alberi';
          case 'bushfire_recovery':
            return 'Ripristino Incendi Boschivi';
          case 'flood_recovery':
            return 'Ripristino Alluvioni & Calamità';
          case 'healthcare_covid':
            return 'Sanità & Settore Medico COVID-19';
          case 'mining':
            return 'Estrazione Mineraria (Solo 417)';
          default:
            return id;
        }
      case 'zh':
        switch (id) {
          case 'tourism_hospitality':
            return '旅游与酒店餐饮业';
          case 'agriculture':
            return '植物种植与畜牧养殖';
          case 'construction':
            return '建筑与土木工程';
          case 'fishing':
            return '商业捕捞与珍珠养殖';
          case 'forestry':
            return '植树造林与伐木伐运';
          case 'bushfire_recovery':
            return '丛林林火灾后重建与恢复';
          case 'flood_recovery':
            return '洪涝风暴等自然灾害救援';
          case 'healthcare_covid':
            return 'COVID-19医疗卫生与医护支持';
          case 'mining':
            return '矿产资源开采（仅限417签证）';
          default:
            return id;
        }
      case 'es':
        switch (id) {
          case 'tourism_hospitality':
            return 'Turismo y Hostelería';
          case 'agriculture':
            return 'Cultivo de Plantas y Ganadería';
          case 'construction':
            return 'Construcción y Obras';
          case 'fishing':
            return 'Pesca y Perlas';
          case 'forestry':
            return 'Silvicultura y Tala';
          case 'bushfire_recovery':
            return 'Recuperación de Incendios';
          case 'flood_recovery':
            return 'Inundaciones y Desastres';
          case 'healthcare_covid':
            return 'Salud y Sector Médico COVID-19';
          case 'mining':
            return 'Minería (Solo Subclase 417)';
          default:
            return id;
        }
      default: // en
        switch (id) {
          case 'tourism_hospitality':
            return 'Tourism & Hospitality';
          case 'agriculture':
            return 'Plant & Animal Cultivation';
          case 'construction':
            return 'Construction';
          case 'fishing':
            return 'Fishing & Pearling';
          case 'forestry':
            return 'Tree Farming & Felling';
          case 'bushfire_recovery':
            return 'Bushfire Recovery';
          case 'flood_recovery':
            return 'Flood & Disaster Recovery';
          case 'healthcare_covid':
            return 'COVID-19 Healthcare & Medical';
          case 'mining':
            return 'Mining (Subclass 417 Only)';
          default:
            return id;
        }
    }
  }

  static String getTableRef(String id, String subclass, String lang) {
    switch (lang) {
      case 'fr':
        switch (id) {
          case 'tourism_hospitality':
            return 'Tableaux 1, 2 & 3 (Nord et Zones Isolées)';
          case 'agriculture':
          case 'construction':
            return 'Tableaux 3 & 4 (Nord & Australie Régionale)';
          case 'fishing':
          case 'forestry':
            return subclass == '462'
                ? 'Tableau 3 UNIQUEMENT (Nord de l\'Australie)'
                : 'Tableaux 3 & 4 (Australie Régionale)';
          case 'bushfire_recovery':
            return 'Tableau 5 (Zones d\'Incendies - après 31 juil 2019)';
          case 'flood_recovery':
            return 'Tableau 6 (Zones de Catastrophe Naturelle - après 31 déc 2021)';
          case 'healthcare_covid':
            return 'Partout en Australie (Tous Codes Postaux)';
          case 'mining':
            return 'Tableaux 3 & 4 (Australie Régionale - 417 Seul)';
          default:
            return '';
        }
      case 'it':
        switch (id) {
          case 'tourism_hospitality':
            return 'Tabelle 1, 2 & 3 (Nord & Aree Remote)';
          case 'agriculture':
          case 'construction':
            return 'Tabelle 3 & 4 (Nord & Australia Regionale)';
          case 'fishing':
          case 'forestry':
            return subclass == '462'
                ? 'SOLO Tabella 3 (Nord Australia)'
                : 'Tabelle 3 & 4 (Australia Regionale)';
          case 'bushfire_recovery':
            return 'Tabella 5 (Aree Incendi Boschivi - dopo 31 lug 2019)';
          case 'flood_recovery':
            return 'Tabella 6 (Aree Calamità Naturali - dopo 31 dic 2021)';
          case 'healthcare_covid':
            return 'Ovunque in Australia (Tutti i CAP)';
          case 'mining':
            return 'Tabelle 3 & 4 (Australia Regionale - Solo 417)';
          default:
            return '';
        }
      case 'zh':
        switch (id) {
          case 'tourism_hospitality':
            return '表1、2和3（澳洲北部及偏远/极偏远地区）';
          case 'agriculture':
          case 'construction':
            return '表3和表4（澳洲北部与常规偏远地区）';
          case 'fishing':
          case 'forestry':
            return subclass == '462'
                ? '仅限表3（澳洲北部区域）'
                : '表3和表4（常规偏远地区）';
          case 'bushfire_recovery':
            return '表5（丛林大火官方认定受灾区 - 2019年7月31日后）';
          case 'flood_recovery':
            return '表6（自然灾害官方认定受灾区 - 2021年12月31日后）';
          case 'healthcare_covid':
            return '全澳任何邮编均有效（包括各大首府都市）';
          case 'mining':
            return '表3和表4（仅限417打工度假签证）';
          default:
            return '';
        }
      case 'es':
        switch (id) {
          case 'tourism_hospitality':
            return 'Tablas 1, 2 y 3 (Norte y Zonas Remotas / Muy Remotas)';
          case 'agriculture':
          case 'construction':
            return 'Tablas 3 y 4 (Norte de Australia y Australia Regional)';
          case 'fishing':
          case 'forestry':
            return subclass == '462'
                ? 'SOLO Tabla 3 (Norte de Australia)'
                : 'Tablas 3 y 4 (Australia Regional)';
          case 'bushfire_recovery':
            return 'Tabla 5 (Áreas Declaradas de Incendio - desde 31 jul 2019)';
          case 'flood_recovery':
            return 'Tabla 6 (Zonas de Desastre Natural - desde 31 dic 2021)';
          case 'healthcare_covid':
            return 'En toda Australia (Todos los CP - desde 31 ene 2020)';
          case 'mining':
            return 'Tablas 3 y 4 (Australia Regional - Exclusivo 417)';
          default:
            return '';
        }
      default: // en
        switch (id) {
          case 'tourism_hospitality':
            return 'Tables 1, 2 & 3 (Northern & Remote/Very Remote)';
          case 'agriculture':
          case 'construction':
            return 'Tables 3 & 4 (Northern & Regional Australia)';
          case 'fishing':
          case 'forestry':
            return subclass == '462'
                ? 'Table 3 ONLY (Northern Australia)'
                : 'Tables 3 & 4 (Regional Australia)';
          case 'bushfire_recovery':
            return 'Table 5 (Bushfire Declared Areas - post 31 Jul 2019)';
          case 'flood_recovery':
            return 'Table 6 (Natural Disaster Declared Areas - post 31 Dec 2021)';
          case 'healthcare_covid':
            return 'Anywhere in Australia (All Postcodes - post 31 Jan 2020)';
          case 'mining':
            return 'Tables 3 & 4 (Regional Australia - 417 Only)';
          default:
            return '';
        }
    }
  }

  static String getDesc(String id, String lang) {
    switch (lang) {
      case 'fr':
        switch (id) {
          case 'tourism_hospitality':
            return '• Hébergement: hôtels, motels, B&B, auberges de jeunesse, campings, entretien ménager commercial et centres d\'accueil.\n• Restauration: cafés, restaurants, vente à emporter, traiteurs, pubs, tavernes, bars et clubs.\n• Activités touristiques: guides touristiques, moniteurs de plongée ou d\'aventure, chauffeurs de navettes touristiques, musées, galeries et parcs de loisirs.';
          case 'agriculture':
            return '• Récolte (picking) et emballage (packing) de fruits et légumes.\n• Taille des vignes et arbres (activité horticole commerciale comme tâche principale).\n• Entretien général des cultures, propagation des plantes ou champignons.\n• Élevage commercial pour vente de bétail ou produits dérivés, haras, garde de troupeaux et feedlots.\n• Traitement primaire des produits animaux (tonte, boucherie, tannage, emballage) et fabrication de produits laitiers.\n• Reboisement environnemental et conservation de la faune/flore.';
          case 'construction':
            return '• Construction de bâtiments résidentiels et non résidentiels.\n• Génie civil et grands travaux d\'infrastructure.\n• Aménagement de terrains et préparation de chantiers.\n• Structure, installation et finition: peinture neuve, clôtures de chantiers, échafaudage (scaffolding) et nettoyage de fin de chantier.';
          case 'fishing':
            return '• Opérations directement liées à la capture et à la pêche commerciale de poissons et crustacés.\n• Prélèvement ou culture des perles et nacres (pearling).';
          case 'forestry':
            return '• Plantation ou entretien d\'arbres destinés à l\'abattage dans une plantation ou forêt commerciale.\n• Abattage des arbres.\n• Transport des grumes abattues jusqu\'à la première scierie ou usine de transformation.';
          case 'bushfire_recovery':
            return '• Travail rémunéré ou bénévole réalisé après le 31 juillet 2019 dans les zones déclarées du Tableau 5.\n• Travaux de reconstruction, d\'agriculture et de réhabilitation des terres, propriétés, bétail ou faune sauvage.\n• Services de soutien et d\'assistance aux communautés locales sinistrées.';
          case 'flood_recovery':
            return '• Travail rémunéré ou bénévole après le 31 décembre 2021 dans les zones touchées par inondations ou tempêtes (Tableau 6).\n• Déblaiement, transport de débris, démolition, terrassement et arrachage d\'arbres.\n• Réparation et reconstruction de routes, ponts, clôtures et habitations.\n• Services d\'accueil, soutien administratif et logistique pour les sinistrés.';
          case 'healthcare_covid':
            return '• Soins médicaux, soins infirmiers, dépistage, traçage des contacts et recherche directement liés à la pandémie COVID-19.\n• Services d\'appui indispensables, tels que la désinfection et le nettoyage d\'installations hospitalières.';
          case 'mining':
            return '• Extraction de charbon, pétrole, gaz, minerais métalliques, carrières de matériaux de construction et services de prospection minière.';
          default:
            return '';
        }
      case 'it':
        switch (id) {
          case 'tourism_hospitality':
            return '• Alloggio: hotel, motel, B&B, ostelli per backpacker, campeggi, pulizie commerciali e centri congressi.\n• Cibo e bevande: caffè, ristoranti, asporto, catering, pub, taverne, bar e club di ospitalità.\n• Servizi turistici: guide ed escursioni, istruttori di immersioni/avventura, autisti turistici, musei, gallerie e parchi a tema.';
          case 'agriculture':
            return '• Raccolta (picking) e confezionamento (packing) di frutta e verdura.\n• Potatura e cura di viti e alberi da frutto (orticoltura commerciale).\n• Manutenzione colture, propagazione piante e funghi.\n• Allevamento di animali a fini commerciali, allevamento cavalli, pascolo del bestiame e feedlot.\n• Prima lavorazione di prodotti animali (tosatura, macelleria, conceria) e caseifici.\n• Rimboschimento ambientale e cura di parchi e zoo.';
          case 'construction':
            return '• Costruzione di edifici residenziali e commerciali.\n• Ingegneria civile e grandi opere infrastrutturali.\n• Sviluppo del terreno e preparazione dei cantieri.\n• Strutture, impiantistica e finiture: pittura di nuove costruzioni, recinzioni da cantiere, ponteggi (scaffolding) e pulizia post-costruzione.';
          case 'fishing':
            return '• Operazioni direttamente legate alla pesca commerciale di specie ittiche.\n• Raccolta e coltivazione di perle e conchiglie (pearling).';
          case 'forestry':
            return '• Piantumazione o cura di alberi destinati all\'abbattimento in foreste commerciali.\n• Abbattimento di alberi.\n• Trasporto dei tronchi dalla foresta alla prima segheria o impianto di lavorazione.';
          case 'bushfire_recovery':
            return '• Lavoro retribuito o di volontariato svolto dopo il 31 luglio 2019 nelle aree della Tabella 5.\n• Edilizia, agricoltura e ripristino di terreni, proprietà, bestiame e fauna.\n• Servizi di supporto e assistenza alle comunità colpite.';
          case 'flood_recovery':
            return '• Lavoro retribuito o di volontariato svolto dopo il 31 dicembre 2021 nelle aree alluvionate (Tabella 6).\n• Pulizia generale, rimozione macerie, demolizioni, rimozione alberi caduti e scavi.\n• Riparazione di edifici, strade, ponti, recinzioni e reti idriche/elettriche.\n• Supporto logistico, caritativo e coordinamento delle consegne ai residenti.';
          case 'healthcare_covid':
            return '• Trattamento medico, assistenza infermieristica, tracciamento contatti, tamponi e ricerca legata al COVID-19.\n• Servizi di supporto critico, inclusa la sanificazione di strutture sanitarie.';
          case 'mining':
            return '• Estrazione di carbone, petrolio e gas, minerali metallici, cave di inerti ed esplorazione mineraria.';
          default:
            return '';
        }
      case 'zh':
        switch (id) {
          case 'tourism_hospitality':
            return '• 住宿服务：酒店、汽车旅馆、B&B民俗、背包客青年旅舍、房车营地、露营地、商业客房保洁及接待中心。\n• 餐饮服务：咖啡馆、各类餐厅、外卖快餐、宴席配餐、酒馆、酒吧及持牌俱乐部服务。\n• 旅游接待：持证导游、户外探险及潜水教练、旅游观光大巴司机、美术馆及博物馆工作人员、旅行社及展演活动支持。';
          case 'agriculture':
            return '• 水果、蔬菜等各类经济作物的采摘（picking）与分选包装（packing）。\n• 葡萄藤与果树修剪整形（必须为商业化园艺生产且为主要职责，非家庭园艺）。\n• 作物日常培育、养护、移栽育苗及菌菇养殖。\n• 商业化禽畜养殖、马匹繁育繁育场、牛群放牧（cattle herding）及育肥栏。\n• 动物副产物初级加工（剪羊毛、初级屠宰、包装皮毛、鞣制）及原奶乳制品初级制作。\n• 环境保护林造林绿化及动物园动植物养护。';
          case 'construction':
            return '• 住宅建筑与非住宅工商业楼宇建造施工。\n• 重型市政及土木工程建设。\n• 土地规划平整与施工场地前期准备服务。\n• 建筑主体结构、机电安装与竣工交付：施工现场绿化景观、新建建筑油漆粉刷、安全围挡架设、脚手架搭拆（scaffolding）以及施工现场清理协助。';
          case 'fishing':
            return '• 商业捕捞鱼类及其他海洋水生经济动物的直接现场作业。\n• 采捕或人工养殖珍珠、天然珍珠贝（pearling）现场工作。';
          case 'forestry':
            return '• 种植、育苗或管护拟行砍伐采伐的人工商业林及林地木材。\n• 商业林区树木采伐作业。\n• 将采伐后的原木从林区直接运输至第一道锯木厂或初级加工厂。';
          case 'bushfire_recovery':
            return '• 2019年7月31日后在官方表5认定的火灾受灾地区开展的有薪或志愿重建工作。\n• 涉及土地、建筑、农场牲畜或野生动物恢复重建的建筑施工、农林农业及修复作业。\n• 向受灾地区居民、常驻人员或志愿者提供直接生活保障与救助支持。';
          case 'flood_recovery':
            return '• 2021年12月31日后在表6认定的洪涝、热带气旋或极端风暴灾区开展的有薪或志愿救灾工作。\n• 灾后清淤排污、垃圾瓦砾运输清理、危房拆除、开挖排渍排水沟、倒伏树木清理及土方转运。\n• 居民住宅、道路设施、人行桥梁、公用管网及农场围栏的抢修加固与重建。\n• 向受灾社区提供救济协调、行政联络、呼叫中心指引及受灾动物转运救护。';
          case 'healthcare_covid':
            return '• 直接参与抗击与应对COVID-19的临床诊疗、专业护理、流调追踪、核酸检测及医学科研。\n• 直接服务于抗疫一线医院、医疗机构和救治设施的深度消杀清洁与后勤支持。';
          case 'mining':
            return '• 煤炭开采、石油与天然气钻采、金属矿石采选、建筑石料采掘、矿产地质勘探及现场采矿配套辅助工程。';
          default:
            return '';
        }
      case 'es':
        switch (id) {
          case 'tourism_hospitality':
            return '• Alojamiento: hoteles, moteles, B&B, hostels de mochileros, caravan parks, campings, housekeeping comercial y centros de recepción.\n• Comida y Bebida: cafeterías, restaurantes, comida para llevar, catering, pubs, tabernas, bares y clubes de hostelería.\n• Servicios Turísticos: guías y operadores de tours, instructores de buceo o aventura, transporte/autobuses turísticos, museos/galerías, agencias de viajes y eventos.';
          case 'agriculture':
            return '• Cosecha (picking) y/o empaquetado (packing) de frutas y verduras.\n• Poda y recorte de viñedos y árboles (debe ser horticultura comercial y tu tarea principal, no jardinería doméstica).\n• Mantenimiento general de cultivos, propagación de plantas u hongos.\n• Cría de animales para venta comercial o sus productos, cría de caballos, pastoreo de ganado (cattle herding) y feedlots.\n• Procesamiento inmediato de productos animales (esquila, carnicería primaria, empaquetado, curtido) y fabricación de lácteos desde materia prima.\n• Conservación ambiental, reforestación y cuidado de fauna/flora en zoológicos.';
          case 'construction':
            return '• Construcción de edificios residenciales y no residenciales.\n• Ingeniería civil y construcción pesada.\n• Urbanización de terrenos y preparación de solares.\n• Estructura, instalación y acabado de obra: paisajismo en solares en construcción, pintura de obra nueva, vallado de obras, andamiaje (scaffolding) y servicios de apoyo/limpieza de obra.';
          case 'fishing':
            return '• Operaciones directamente relacionadas con la captura o pesca comercial de peces y otras especies acuáticas.\n• Extracción o cultivo de perlas y nácar (pearling).';
          case 'forestry':
            return '• Plantación o cuidado de árboles en plantaciones o bosques destinados a la tala.\n• Tala de árboles en plantaciones o bosques.\n• Transporte de troncos talados desde el bosque hasta su primera serrería o planta de procesado.';
          case 'bushfire_recovery':
            return '• Trabajo remunerado o voluntario realizado tras el 31 de julio de 2019 en las zonas declaradas de la Tabla 5 (actualizada el 5 de abril de 2025).\n• Construcción, agricultura o cualquier labor de restitución y restauración de tierras, propiedades, ganado o fauna silvestre.\n• Servicios de apoyo y asistencia a personas que viven, trabajan o son voluntarias en las zonas afectadas.';
          case 'flood_recovery':
            return '• Trabajo remunerado o voluntario desde el 31 de diciembre de 2021 en zonas afectadas por inundaciones, ciclones o clima severo (Tabla 6, vigente desde el 5 de abril de 2025).\n• Limpieza general, retirada de escombros, demolición, excavación de zanjas, retirada de árboles y movimiento de tierras.\n• Reparación o reconstrucción de viviendas, carreteras, puentes, suministros y vallas.\n• Apoyo caritativo, administrativo, call-centre, atención al afectado, coordinación y entregas en comunidades damnificadas, así como rescate de animales.\n• En ImmiAccount debes seleccionar "flood recovery - paid" o "flood recovery - volunteer".';
          case 'healthcare_covid':
            return '• Tratamiento médico, enfermería, rastreo de contactos, pruebas diagnósticas e investigación en respuesta directa al COVID-19.\n• Servicios de soporte como limpieza de centros médicos, hospitales y equipamiento sanitario vinculados a la respuesta COVID-19.';
          case 'mining':
            return '• Extracción de carbón, petróleo y gas, minerales metálicos, canteras, exploración y servicios de soporte minero.';
          default:
            return '';
        }
      default: // en
        switch (id) {
          case 'tourism_hospitality':
            return '• Accommodation: hotels, motels, B&Bs, backpacker hostels, caravan parks, camping grounds, commercial housekeeping, boarding houses & reception centres.\n• Food & Beverage: cafes, restaurants, takeaway food services, catering, pubs, taverns, bars and hospitality clubs.\n• Tourist Services: tour guides/operators, outdoor adventure or dive instructors, tourist transport/bus drivers, gallery/museum workers, travel agencies & event/entertainment venues.';
          case 'agriculture':
            return '• Harvesting and/or packing fruit and vegetable crops.\n• Pruning and trimming vines and trees (must be commercial horticultural activities and your primary task).\n• General crop maintenance, cultivating/propagating plants or fungi.\n• Maintaining animals for commercial sale or bodily produce, horse breeding/stud farming, cattle herding & feedlots.\n• Immediate processing of animal products (shearing, butchery, packing, tanning) and manufacturing dairy products from raw material.\n• Conservation, environmental reforestation and zoo plant/animal cultivation.';
          case 'construction':
            return '• Residential and non-residential building construction.\n• Heavy and civil engineering construction.\n• Land development and site preparation services.\n• Building structure, installation and completion services: landscaping on construction sites, painting new buildings, erecting fences on construction sites, scaffolding, and site support/cleaning services.';
          case 'fishing':
            return '• Conducting operations relating directly to taking or catching fish and other aquatic species.\n• Taking or culturing pearls or pearl shell.';
          case 'forestry':
            return '• Planting or tending trees in a plantation or forest that are intended to be felled.\n• Felling trees in a plantation or forest.\n• Transporting felled trees or parts of trees from the plantation/forest to where they are first milled or processed.';
          case 'bushfire_recovery':
            return '• Paid or volunteer recovery work carried out after 31 July 2019 in Table 5 declared areas (updated 5 April 2025).\n• Construction, farming, or any work in association with restitution/restoration of land, property, farm animals or wildlife.\n• Providing support services or assistance to people living, working or volunteering in affected areas.';
          case 'flood_recovery':
            return '• Paid or volunteer recovery work from 31 Dec 2021 in areas affected by flood, cyclone or severe weather (Table 6, effective 5 April 2025).\n• Clean-up, rubbish transport, building demolition, trench digging, tree removal and earth moving.\n• Construction/repair of buildings, roads, footpaths, bridges, utilities and fences.\n• Charity, administrative, call-centre, customer service, coordination & delivery support for affected communities.\n• Caring for, transporting and rehabilitating affected animals.\n• In ImmiAccount select "flood recovery - paid" or "flood recovery - volunteer".';
          case 'healthcare_covid':
            return '• Medical treatment, nursing, contact tracing, testing and research directly involved in the response to COVID-19.\n• Support services such as cleaning of medical and healthcare facilities and equipment directly involved in responding to COVID-19.';
          case 'mining':
            return '• Coal mining, oil and gas extraction, metal ore mining, construction material mining, exploration and mining support services.';
          default:
            return '';
        }
    }
  }

  static String getExclusions(String id, String subclass, String lang) {
    switch (lang) {
      case 'fr':
        switch (id) {
          case 'tourism_hospitality':
            return 'N\'inclut PAS: caves viticoles ou brasseries ne proposant pas d\'activités touristiques prédominantes (cellar door); nettoyage général ou sécurité non spécifiquement destinés aux touristes; résidences étudiantes.';
          case 'agriculture':
            return 'N\'inclut PAS: la transformation secondaire (vinification, brassage, distillation, charcuterie industrielle ou vente au détail) ni le jardinage domestique.';
          case 'construction':
            return 'N\'inclut PAS: la construction navale; la fabrication industrielle de matériaux (acier, béton préfabriqué) ni les opérations minières.';
          case 'fishing':
            return 'Pour le visa 462, la pêche et perliculture sont strictement limitées au Nord de l\'Australie (Tableau 3: Territoire du Nord, nord du QLD et du WA).';
          case 'forestry':
            return 'Pour le visa 462, la sylviculture et l\'abattage sont strictement limités au Nord de l\'Australie (Tableau 3).';
          case 'bushfire_recovery':
            return 'N\'inclut PAS: l\'hôtellerie ou l\'administration pour une entreprise qui n\'a pas subi de dommages directs dus aux incendies.';
          case 'flood_recovery':
            return 'N\'inclut PAS: l\'hôtellerie, le nettoyage ou les tâches de bureau pour une entreprise non sinistrée.';
          case 'healthcare_covid':
            return 'N\'inclut PAS: kinésithérapie générale, psychologie sans lien direct avec le COVID-19, fabrication pharmaceutique générale ou nettoyage de locaux non médicaux.';
          case 'mining':
            return 'IMPORTANT: Les mines sont STRICTEMENT réservées au visa 417. Elles ne sont PAS éligibles pour le visa 462.';
          default:
            return '';
        }
      case 'it':
        switch (id) {
          case 'tourism_hospitality':
            return 'NON include: cantine o birrifici che non offrono principalmente servizi turistici; pulizie o sicurezza non destinate ai turisti; residenze studentesche.';
          case 'agriculture':
            return 'NON include: trasformazione secondaria (vinificazione, birrificazione, salumi o vendita al dettaglio) o giardinaggio domestico.';
          case 'construction':
            return 'NON include: cantieri navali; produzione industriale di materiali edili (acciaio, cemento); miniere.';
          case 'fishing':
            return 'Per il visto 462, la pesca e perle è limitata rigorosamente al Nord Australia (Tabella 3: tutto NT, nord QLD e WA).';
          case 'forestry':
            return 'Per il visto 462, silvicoltura e abbattimento alberi valgono SOLO nel Nord Australia (Tabella 3).';
          case 'bushfire_recovery':
            return 'NON include: lavoro in aziende non colpite direttamente da incendi boschivi.';
          case 'flood_recovery':
            return 'NON include: ospitalità, pulizie o lavoro d\'ufficio per aziende non danneggiate da calamità naturali.';
          case 'healthcare_covid':
            return 'NON include: fisioterapia generale, salute mentale non legata a COVID-19, pulizia di edifici non medici.';
          case 'mining':
            return 'IMPORTANTE: Il settore minerario è approvato ESCLUSIVAMENTE per il visto 417. NON è valido per il visto 462.';
          default:
            return '';
        }
      case 'zh':
        switch (id) {
          case 'tourism_hospitality':
            return '官方明确排除：非以接待游客为主导业务的酒庄、啤酒厂或蒸馏厂（如单纯农场种植与酿造无品鉴接待）；非直接向游客提供服务的日常保洁、零售杂货、普通货运与安保公司；各类学校及学生宿舍。';
          case 'agriculture':
            return '官方明确排除：次级深加工业务（如商业化酿酒、啤酒酿造、粮食研磨、熟食香肠精加工，或乳品肉制品门市零售）；私人家庭庭院维护美化。';
          case 'construction':
            return '官方明确排除：造船厂或各类船舶制造修理；脱离现场在独立工厂批量制造建筑材料（如钢铁冶炼轧制或预拌混凝土工厂）；采矿业施工作业。';
          case 'fishing':
            return '462签证特别限制：针对462打工度假签证，渔业与珍珠养殖严格限定在澳洲北部区域（表3：北领地全境、昆士兰北部及西澳北部官方指定邮编）。';
          case 'forestry':
            return '462签证特别限制：针对462打工度假签证，商业林木种植与采伐严格限定在澳洲北部区域（表3）。';
          case 'bushfire_recovery':
            return '官方明确排除：未直接遭受林火破坏侵袭的普通餐饮酒店、商业保洁或行政文员岗位，或与火灾灾后恢复无关的普通劳务。';
          case 'flood_recovery':
            return '官方明确排除：未遭受洪涝极端气象灾害直接损坏影响的普通企业餐饮、保洁或内勤事务。';
          case 'healthcare_covid':
            return '官方明确排除：常规非抗疫专科辅助医疗（如常规物理治疗、脊椎按摩、非涉疫心理咨询）、非涉疫老年护理、兽药制造、普通门诊前台接待或非医疗办公区保洁。';
          case 'mining':
            return '重磅法定规则：采矿业（Mining）官方仅对417类工作假期签证有效；移民局严正申明462打工度假签证在任何地区从事采矿均不具备二签/三签计算资格。';
          default:
            return '';
        }
      case 'es':
        switch (id) {
          case 'tourism_hospitality':
            return 'NO incluye: bodegas, cervecerías o destilerías que no presten principalmente servicios turísticos (ej. cata/cellar door); empresas generales de limpieza, tiendas, transporte o seguridad; residencias estudiantiles.';
          case 'agriculture':
            return 'NO incluye: procesamiento secundario (elaboración de vino, cerveza, destilación, molienda, embutidos o venta minorista de lácteos/carnicería) ni jardinería doméstica.';
          case 'construction':
            return 'NO incluye: construcción naval o de barcos; fabricación en planta de materiales de construcción (como acero u hormigón); ni operaciones mineras.';
          case 'fishing':
            return 'Para la Subclase 462, la pesca y cultivo de perlas solo es válida en el Norte de Australia (Tabla 3: todo NT y códigos del norte de QLD y WA).';
          case 'forestry':
            return 'Para la Subclase 462, la silvicultura y tala de árboles solo es válida en el Norte de Australia (Tabla 3).';
          case 'bushfire_recovery':
            return 'NO incluye: trabajo de hostelería, limpieza o administración para negocios que no hayan sido afectados directamente por el incendio forestal.';
          case 'flood_recovery':
            return 'NO incluye: hostelería, limpieza o administración en empresas que no hayan sido afectadas por el desastre natural.';
          case 'healthcare_covid':
            return 'NO incluye: fisioterapia, logopedia, quiropráctica, cuidado de mayores/discapacidad sin brote de COVID-19, fabricación farmacéutica, recepción/administración médica ni limpieza de centros no médicos.';
          case 'mining':
            return 'IMPORTANTE: La minería está aprobada ÚNICAMENTE para la Subclase 417. NO es una industria válida para la Subclase 462 según Home Affairs.';
          default:
            return '';
        }
      default: // en
        switch (id) {
          case 'tourism_hospitality':
            return 'Does NOT include: wineries/breweries/distilleries that do not predominantly provide tourist services; general cleaning, retail, transport or security companies not primarily serving tourists; schools/student residences.';
          case 'agriculture':
            return 'Does NOT include: secondary processing (winemaking, brewing, distillation, milling, manufacturing small goods, or retail of dairy/butchery products) or domestic garden maintenance.';
          case 'construction':
            return 'Does NOT include: ship or boat building; manufacturing materials used in construction (such as steel or concrete manufacturing); mining operations.';
          case 'fishing':
            return 'For Subclass 462, Fishing & Pearling is strictly restricted to Northern Australia (Table 3: all of NT, plus approved northern postcodes in QLD and WA).';
          case 'forestry':
            return 'For Subclass 462, Tree Farming & Felling is strictly restricted to Northern Australia (Table 3).';
          case 'bushfire_recovery':
            return 'Does NOT include: hospitality, cleaning or administrative work for a business that is not directly affected by a bushfire or where work is not a direct consequence of bushfire damage.';
          case 'flood_recovery':
            return 'Does NOT include: hospitality, cleaning or administrative work for a business not affected by a natural disaster.';
          case 'healthcare_covid':
            return 'Does NOT include: General Allied Health (physiotherapy, speech pathology, chiropractic), mental health not related to COVID-19, aged/disability care not responding to a COVID-19 outbreak, medical/vet manufacturing, medical reception/admin, or cleaning non-medical facilities.';
          case 'mining':
            return 'IMPORTANT: Mining is ONLY approved for Working Holiday Subclass 417. It is NOT an eligible industry for Work and Holiday Subclass 462.';
          default:
            return '';
        }
    }
  }

  static String getLegalTip(String id, String subclass, bool isEligible, String lang) {
    switch (lang) {
      case 'fr':
        if (id == 'tourism_hospitality') {
          if (subclass == '462') {
            return isEligible
                ? 'ÉLIGIBLE: Ce code postal est situé dans le Nord de l\'Australie (Tableau 3) ou en zone isolée (Tableaux 1 & 2).'
                : 'NON ÉLIGIBLE ICI: Pour le visa 462, le tourisme et l\'hôtellerie ne comptent QUE dans le Nord ou en zone très isolée.';
          } else {
            return isEligible
                ? 'ÉLIGIBLE: Vérifiez l\'éligibilité territoriale pour le visa 417.'
                : 'NON ÉLIGIBLE: Zone métropolitaine exclue pour le tourisme sous le visa 417.';
          }
        } else if (id == 'agriculture' || id == 'construction') {
          return isEligible
              ? 'ÉLIGIBLE: Approuvé dans le Nord (Tableau 3) et en Australie Régionale (Tableau 4) pour visas 462 et 417.'
              : 'NON ÉLIGIBLE ICI: Code postal métropolitain hors Tableaux 3 et 4.';
        } else if (id == 'fishing' || id == 'forestry') {
          if (subclass == '462') {
            return isEligible
                ? 'ÉLIGIBLE: Situé dans le Nord de l\'Australie (Tableau 3).'
                : 'NON ÉLIGIBLE ICI: Pour le visa 462, ne compte QUE dans le Nord de l\'Australie (Tableau 3).';
          } else {
            return isEligible
                ? 'ÉLIGIBLE: Approuvé dans toute l\'Australie Régionale pour le visa 417.'
                : 'NON ÉLIGIBLE ICI: Zone métropolitaine exclue.';
          }
        } else if (id == 'bushfire_recovery') {
          return isEligible
              ? 'ÉLIGIBLE (Tableau 5): Ce code postal est officiellement reconnu zone sinistrée par incendies.'
              : 'NON ÉLIGIBLE ICI: Code postal non répertorié au Tableau 5 (Incendies).';
        } else if (id == 'flood_recovery') {
          return isEligible
              ? 'ÉLIGIBLE (Tableau 6): Ce code postal est reconnu zone officielle de catastrophe naturelle.'
              : 'NON ÉLIGIBLE ICI: Code postal non répertorié au Tableau 6 (Inondations).';
        } else if (id == 'healthcare_covid') {
          return 'ÉLIGIBLE PARTOUT: Le travail médical COVID-19 compte dans toute l\'Australie (métropoles incluses).';
        } else if (id == 'mining') {
          return isEligible
              ? 'ÉLIGIBLE: Approuvé pour le visa 417 en Australie Régionale.'
              : 'NON ÉLIGIBLE: Zone métropolitaine exclue.';
        }
        return '';
      case 'it':
        if (id == 'tourism_hospitality') {
          if (subclass == '462') {
            return isEligible
                ? 'VALIDO: Il CAP appartiene al Nord Australia (Tabella 3) o alle Aree Remote (Tabelle 1 & 2).'
                : 'NON VALIDO QUI: Per il visto 462, turismo e ospitalità contano SOLO nel Nord o in zone remote.';
          } else {
            return isEligible
                ? 'VALIDO: Area regionale approvata per la sottoclasse 417.'
                : 'NON VALIDO: Area metropolitana non consentita per ospitalità sotto il 417.';
          }
        } else if (id == 'agriculture' || id == 'construction') {
          return isEligible
              ? 'VALIDO: Approvato nel Nord (Tabella 3) e in Australia Regionale (Tabella 4) per visti 462 e 417.'
              : 'NON VALIDO QUI: CAP metropolitano escluso dalle Tabelle 3 e 4.';
        } else if (id == 'fishing' || id == 'forestry') {
          if (subclass == '462') {
            return isEligible
                ? 'VALIDO: Situato nel Nord Australia (Tabella 3).'
                : 'NON VALIDO QUI: Per il visto 462, conta SOLO nel Nord Australia (Tabella 3).';
          } else {
            return isEligible
                ? 'VALIDO: Approvato in Australia Regionale per la sottoclasse 417.'
                : 'NON VALIDO QUI: Area metropolitana.';
          }
        } else if (id == 'bushfire_recovery') {
          return isEligible
              ? 'VALIDO (Tabella 5): CAP incluso nella Tabella 5 ufficiale di aree incendiate.'
              : 'NON VALIDO QUI: CAP non presente nella Tabella 5 (Incendi).';
        } else if (id == 'flood_recovery') {
          return isEligible
              ? 'VALIDO (Tabella 6): CAP incluso nella Tabella 6 ufficiale di calamità naturali.'
              : 'NON VALIDO QUI: CAP non presente nella Tabella 6 (Alluvioni).';
        } else if (id == 'healthcare_covid') {
          return 'VALIDO IN TUTTA AUSTRALIA: Il settore sanitario critico COVID-19 vale ovunque (città incluse).';
        } else if (id == 'mining') {
          return isEligible
              ? 'VALIDO: Approvato per la sottoclasse 417 in Australia Regionale.'
              : 'NON VALIDO: Area metropolitana.';
        }
        return '';
      case 'zh':
        if (id == 'tourism_hospitality') {
          if (subclass == '462') {
            return isEligible
                ? '合规有效：该邮编位于澳洲北部区域（表3）或偏远/极偏远地区（表1和表2）。'
                : '在此无效：对于462打工度假签证，旅游与酒店餐饮业仅在澳洲北部（表3）或偏远极偏远地区（表1和表2）有效。';
          } else {
            return isEligible
                ? '合规有效：对于417签证，该邮编处于有效偏远区域。'
                : '在此无效：大都市区域不能以旅游酒店业计入417续签。';
          }
        } else if (id == 'agriculture' || id == 'construction') {
          return isEligible
              ? '合规有效：该邮编属于澳洲北部（表3）或常规偏远地区（表4），462和417均适用。'
              : '在此无效：首府大都市邮编，不在表3和表4范围内。';
        } else if (id == 'fishing' || id == 'forestry') {
          if (subclass == '462') {
            return isEligible
                ? '合规有效：邮编位于澳洲北部区域（表3）。'
                : '在此无效：对于462签证，渔业与林业仅在澳洲北部（表3）被认可。';
          } else {
            return isEligible
                ? '合规有效：417签证在澳洲常规偏远地区普遍认可。'
                : '在此无效：首府大都市区域除外。';
          }
        } else if (id == 'bushfire_recovery') {
          return isEligible
              ? '合规有效（表5）：该邮编属于官方认定的林火受灾恢复区。'
              : '在此无效：该邮编未列入表5林火灾害受灾名录。';
        } else if (id == 'flood_recovery') {
          return isEligible
              ? '合规有效（表6）：该邮编属于官方认定的洪涝自然灾害救灾区。'
              : '在此无效：该邮编未列入表6自然灾害名录。';
        } else if (id == 'healthcare_covid') {
          return '全澳通用有效：COVID-19抗疫关键医疗卫生工作在全澳任何地点均可计入续签。';
        } else if (id == 'mining') {
          return isEligible
              ? '合规有效：仅限417签证在偏远地区认可。'
              : '在此无效：大都市区域。';
        }
        return '';
      case 'es':
        if (id == 'tourism_hospitality') {
          if (subclass == '462') {
            return isEligible
                ? 'VÁLIDO: El código postal pertenece al Norte de Australia (Tabla 3) o a Australia Remota / Muy Remota (Tablas 1 y 2).'
                : 'NO VÁLIDO AQUÍ: En la Subclase 462, turismo y hostelería SOLO computa en el Norte de Australia (Tabla 3) o en áreas Remotas y Muy Remotas (Tablas 1 y 2).';
          } else {
            return isEligible
                ? 'VÁLIDO: Área regional aprobada para Subclase 417.'
                : 'NO VÁLIDO: Área metropolitana excluida para hostelería bajo 417.';
          }
        } else if (id == 'agriculture' || id == 'construction') {
          return isEligible
              ? 'VÁLIDO: Código postal aprobado en Norte de Australia (Tabla 3) o Australia Regional (Tabla 4) para subclases 462 y 417.'
              : 'NO VÁLIDO AQUÍ: Código postal metropolitano fuera de las Tablas 3 y 4.';
        } else if (id == 'fishing' || id == 'forestry') {
          if (subclass == '462') {
            return isEligible
                ? 'VÁLIDO: Ubicado en el Norte de Australia (Tabla 3).'
                : 'NO VÁLIDO AQUÍ: En la Subclase 462, pesca y tala SOLO computa en el Norte de Australia (Tabla 3).';
          } else {
            return isEligible
                ? 'VÁLIDO: Aprobado en Australia Regional para Subclase 417.'
                : 'NO VÁLIDO AQUÍ: Área metropolitana.';
          }
        } else if (id == 'bushfire_recovery') {
          return isEligible
              ? 'VÁLIDO (Tabla 5): Este código postal está incluido en la Tabla 5 oficial de zonas declaradas de incendio.'
              : 'NO VÁLIDO AQUÍ: Este código postal no figura en la Tabla 5 de zonas declaradas por incendio.';
        } else if (id == 'flood_recovery') {
          return isEligible
              ? 'VÁLIDO (Tabla 6): Este código postal está incluido en la Tabla 6 oficial de zonas declaradas por desastre natural / inundación.'
              : 'NO VÁLIDO AQUÍ: Este código postal no figura en la Tabla 6 de desastres naturales.';
        } else if (id == 'healthcare_covid') {
          return 'VÁLIDO EN TODA AUSTRALIA: El trabajo sanitario crítico COVID-19 computa en cualquier código postal de Australia (incluidas capitales metropolitanas).';
        } else if (id == 'mining') {
          return isEligible
              ? 'VÁLIDO: Aprobado para la Subclase 417 en Australia Regional.'
              : 'NO VÁLIDO: En áreas metropolitanas.';
        }
        return '';
      default: // en
        if (id == 'tourism_hospitality') {
          if (subclass == '462') {
            return isEligible
                ? 'ELIGIBLE: Postcode is in Northern Australia (Table 3) or Remote / Very Remote Australia (Tables 1 & 2).'
                : 'INELIGIBLE HERE: For Subclass 462, tourism & hospitality ONLY qualifies in Northern Australia (Table 3) or Remote & Very Remote Australia (Tables 1 & 2).';
          } else {
            return isEligible
                ? 'ELIGIBLE: Regional area approved under Subclass 417.'
                : 'INELIGIBLE: Metropolitan area outside 417 hospitality rules.';
          }
        } else if (id == 'agriculture' || id == 'construction') {
          return isEligible
              ? 'ELIGIBLE: Approved in Northern Australia (Table 3) and Regional Australia (Table 4) for both 462 and 417.'
              : 'INELIGIBLE HERE: Metropolitan postcode outside Table 3 and Table 4.';
        } else if (id == 'fishing' || id == 'forestry') {
          if (subclass == '462') {
            return isEligible
                ? 'ELIGIBLE: Located in Northern Australia (Table 3).'
                : 'INELIGIBLE HERE: Under Subclass 462, fishing & forestry ONLY count in Northern Australia (Table 3).';
          } else {
            return isEligible
                ? 'ELIGIBLE: Approved across Regional Australia for Subclass 417.'
                : 'INELIGIBLE HERE: Metropolitan area.';
          }
        } else if (id == 'bushfire_recovery') {
          return isEligible
              ? 'ELIGIBLE (Table 5): This postcode is an official Bushfire Declared Area.'
              : 'INELIGIBLE HERE: Postcode is not listed in Table 5 (Bushfire declared areas).';
        } else if (id == 'flood_recovery') {
          return isEligible
              ? 'ELIGIBLE (Table 6): This postcode is an official Natural Disaster Declared Area.'
              : 'INELIGIBLE HERE: Postcode is not listed in Table 6 (Natural disaster declared areas).';
        } else if (id == 'healthcare_covid') {
          return 'ELIGIBLE NATIONWIDE: Critical COVID-19 medical and healthcare work qualifies anywhere in Australia (including metropolitan cities).';
        } else if (id == 'mining') {
          return isEligible
              ? 'ELIGIBLE: Approved for Subclass 417 in Regional Australia.'
              : 'INELIGIBLE: Metropolitan area.';
        }
        return '';
    }
  }

  static String getSummaryTitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Éligibilité par Secteur (Home Affairs)';
      case 'it':
        return 'Idoneità per Settore (Home Affairs)';
      case 'zh':
        return '各行业官方合规资格（移民局规定）';
      case 'es':
        return 'Elegibilidad por Industria (Home Affairs)';
      default:
        return 'Official Industry Eligibility (Home Affairs)';
    }
  }

  static String getValidBadge(int eligibleCount, int totalCount, String lang) {
    switch (lang) {
      case 'fr':
        return '$eligibleCount/$totalCount Valides';
      case 'it':
        return '$eligibleCount/$totalCount Validi';
      case 'zh':
        return '$eligibleCount/$totalCount 行业合规';
      case 'es':
        return '$eligibleCount/$totalCount Válidos';
      default:
        return '$eligibleCount/$totalCount Valid';
    }
  }

  static String getSummaryIntro(String postcode, String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return 'Secteurs approuvés pour le code postal $postcode sous le visa $subclass (appuyez sur un secteur ci-dessous pour les rôles et exclusions):';
      case 'it':
        return 'Settori approvati per il CAP $postcode sotto la sottoclasse $subclass (tocca un settore per mansioni ed esclusioni complete):';
      case 'zh':
        return '在签证Subclass $subclass下，邮编 $postcode 的获批行业（点击下方任意行业即可查看完整岗位清单及官方排除细则）：';
      case 'es':
        return 'Sectores aprobados para el CP $postcode bajo la Subclase $subclass (toca cualquier sector abajo para ver puestos y exclusiones oficiales):';
      default:
        return 'Approved industries for postcode $postcode under Visa Subclass $subclass (tap any sector below for full role lists and exclusions):';
    }
  }

  static String getViewAllButton(String lang) {
    switch (lang) {
      case 'fr':
        return 'Voir tous les secteurs, tableaux 1 à 6 & règles officielles';
      case 'it':
        return 'Vedi tutti i settori, tabelle 1–6 & regole ufficiali';
      case 'zh':
        return '查看全行业分类、附表1至6及官方移民局细则';
      case 'es':
        return 'Ver todas las industrias, tablas 1–6 y normativa oficial';
      default:
        return 'View All Industries, Tables 1–6 & Official Rules';
    }
  }

  static String getModalTitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Travail Éligible Spécifié (Home Affairs)';
      case 'it':
        return 'Lavoro Specificato Approvato (Home Affairs)';
      case 'zh':
        return '特定区域合规工作（移民局Specified Work）';
      case 'es':
        return 'Trabajo Especificado Aprobado (Home Affairs)';
      default:
        return 'Specified Work Eligibility (Home Affairs)';
    }
  }

  static String getModalSubtitle(String postcode, String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return 'Code Postal $postcode • Sous-classe $subclass • Tableaux 1 à 6';
      case 'it':
        return 'CAP $postcode • Sottoclasse $subclass • Tabelle 1 a 6';
      case 'zh':
        return '邮编 $postcode • 签证类别 $subclass • 附表1至附表6';
      case 'es':
        return 'Código Postal $postcode • Subclase $subclass • Tablas 1 a 6';
      default:
        return 'Postcode $postcode • Visa Subclass $subclass • Tables 1 to 6';
    }
  }

  static String getEligibilityBadge(bool isEligible, String lang) {
    switch (lang) {
      case 'fr':
        return isEligible ? '✓ ÉLIGIBLE' : '✗ NON ÉLIGIBLE';
      case 'it':
        return isEligible ? '✓ VALIDO' : '✗ NON VALIDO';
      case 'zh':
        return isEligible ? '✓ 具备续签资格' : '✗ 不具备资格';
      case 'es':
        return isEligible ? '✓ VÁLIDO' : '✗ NO VÁLIDO';
      default:
        return isEligible ? '✓ ELIGIBLE' : '✗ INELIGIBLE';
    }
  }

  static String getApprovedRolesHeader(String lang) {
    switch (lang) {
      case 'fr':
        return 'Rôles & Activités Approuvés (Home Affairs):';
      case 'it':
        return 'Mansioni & Attività Approvate (Home Affairs):';
      case 'zh':
        return '移民局官方认可岗位与具体工种（Approved Roles）：';
      case 'es':
        return 'Puestos y Actividades Aprobadas (Home Affairs):';
      default:
        return 'Approved Roles & Activities (Home Affairs):';
    }
  }

  static String getExclusionsHeader(String lang) {
    switch (lang) {
      case 'fr':
        return '⚠️ Exclusions Officielles (Ne Compte Pas):';
      case 'it':
        return '⚠️ Esclusioni Ufficiali (Non Computabile):';
      case 'zh':
        return '⚠️ 官方明确排除范围（不计入续签天数）：';
      case 'es':
        return '⚠️ Exclusiones Oficiales (No Computa):';
      default:
        return '⚠️ Official Exclusions (Does Not Count):';
    }
  }

  // --- ADDITIONAL HELPERS FOR POSTCODE VALIDATOR & REGIONAL WORK ---

  static String getFlexibilityRule(String lang) {
    switch (lang) {
      case 'fr':
        return 'Règle de flexibilité Home Affairs : Le travail soutenant les opérations d\'une industrie éligible (comme le support administratif ou le nettoyage dans une ferme, hôtel ou chantier éligible) dans un code postal éligible peut être accepté.';
      case 'it':
        return 'Regola di flessibilità Home Affairs: Il lavoro di supporto alle operazioni di un settore idoneo (come supporto amministrativo o pulizia in una fattoria, hotel o cantiere idoneo) in un CAP idoneo può essere accettato.';
      case 'zh':
        return '移民局灵活性规则：在合规邮编区域内为指定行业运营提供支持的工作（例如在合格农场、酒店或工地的行政或清洁支持服务）亦可被认可。';
      case 'es':
        return 'Criterio de Flexibilidad de Home Affairs: El trabajo de apoyo a las operaciones de una industria elegible (como soporte administrativo o limpieza dentro de una granja, hotel u obra en un código postal válido) también puede ser aceptado.';
      default:
        return 'Home Affairs Flexibility Rule: Work supporting the ongoing operations of a specified industry (such as administrative or cleaning support services at an eligible farm, hotel or construction site) in an eligible postcode may be accepted.';
    }
  }

  static String getMatrixValidBadge(bool isEligible, String lang) {
    switch (lang) {
      case 'fr':
        return isEligible ? 'VALIDE' : 'NON VALIDE';
      case 'it':
        return isEligible ? 'VALIDO' : 'NON VALIDO';
      case 'zh':
        return isEligible ? '有效' : '无效';
      case 'es':
        return isEligible ? 'SÍ VALE' : 'NO VALE';
      default:
        return isEligible ? 'VALID' : 'INVALID';
    }
  }

  static String getTapForRulesHint(String lang) {
    switch (lang) {
      case 'fr':
        return 'Toucher pour rôles et règles';
      case 'it':
        return 'Tocca per ruoli e mansioni';
      case 'zh':
        return '轻触查看岗位与细则';
      case 'es':
        return 'Toca para ver puestos';
      default:
        return 'Tap for rules & roles';
    }
  }

  static String getGotItButton(String lang) {
    switch (lang) {
      case 'fr':
        return 'Compris';
      case 'it':
        return 'Ho capito';
      case 'zh':
        return '知道了';
      case 'es':
        return 'Entendido';
      default:
        return 'Got It';
    }
  }

  static String getOfficialVerifyButton(String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return 'Vérifier sur le site officiel Home Affairs (Sous-classe $subclass)';
      case 'it':
        return 'Verifica sul sito ufficiale Home Affairs (Sottoclasse $subclass)';
      case 'zh':
        return '在移民局官网核验指定工作细则（Subclass $subclass）';
      case 'es':
        return 'Consultar Web Oficial de Home Affairs (Specified $subclass Work)';
      default:
        return 'Verify on Official Home Affairs Website';
    }
  }

  static String getKeyRulesTitle(String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return '📋 Règles Officielles Clés (Sous-classe $subclass)';
      case 'it':
        return '📋 Regole Ufficiali Chiave (Sottoclasse $subclass)';
      case 'zh':
        return '📋 移民局核心官方规则（签证类别 $subclass）';
      case 'es':
        return '📋 Resumen Oficial de Requisitos (Home Affairs Subclase $subclass)';
      default:
        return '📋 Key Official Rules (Specified Subclass $subclass Work)';
    }
  }

  static String getKeyRulesBody(String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return '• 2e Visa : Minimum 3 mois (88 jours civils) de travail spécifié.\n• 3e Visa : Minimum 6 mois (179 jours civils) de travail spécifié après le 1er juillet 2019.\n• Équivalent Temps Plein : Travailler les heures temps plein standard du secteur par semaine (ex. 5 jours / 35–38h) compte comme 7 jours civils.\n• Travail Rémunéré : Doit être payé selon le droit australien avec fiches de paie (bénévolat accepté uniquement pour feux de brousse/inondations).\n• Note Mines : L\'exploitation minière est UNIQUEMENT éligible pour la sous-classe 417, PAS pour la sous-classe 462.';
      case 'it':
        return '• 2° Visto: Minimo 3 mesi (88 giorni di calendario) di lavoro specificato.\n• 3° Visto: Minimo 6 mesi (179 giorni di calendario) di lavoro specificato dopo il 1° luglio 2019.\n• Settimana Piena: Lavorare la settimana piena standard del settore (es. 5 giorni / 35–38h) conta come 7 giorni di calendario.\n• Lavoro Retribuito: Deve essere retribuito secondo la legge australiana con buste paga (volontariato accettato solo per incendi/alluvioni).\n• Nota Miniere: L\'estrazione mineraria è idonea SOLO per la sottoclasse 417, NON per la 462.';
      case 'zh':
        return '• 二签：至少完成3个月（88个自然日）的合规指定工作。\n• 三签：自2019年7月1日起，至少完成6个月（179个自然日）的合规指定工作。\n• 全职等效计算：若单周达到该行业法定全职天数或工时（如5天/35-38小时），该周按完整7个自然日计入。\n• 必须带薪与正式工资单：所有工作必须严格按照澳洲劳工法支付薪酬并提供合法工资单（仅限官方特批的林火/洪涝灾害恢复志愿工作可免薪）。\n• 采矿业注意：采矿业仅对417签证有效，462签证无法通过采矿获得续签天数。';
      case 'es':
        return '• 2º Visado: Mínimo 3 meses (88 días naturales) de trabajo especificado.\n• 3r Visado: Mínimo 6 meses (179 días naturales) de trabajo especificado.\n• Regla de Semana Completa: Si trabajas la jornada semanal completa estándar de la industria (ej. 5 días / 35–38h), computan los 7 días de la semana.\n• Trabajo Remunerado: Debe pagarse según la ley australiana con nóminas/payslips (solo se admite voluntariado en recuperación oficial de incendios o inundaciones).\n• Nota sobre Minería: La minería SOLO computa para la Subclase 417, NO para la Subclase 462.';
      default:
        return '• 2nd Visa: Minimum 3 months (88 calendar days) of specified work.\n• 3rd Visa: Minimum 6 months (179 calendar days) of specified work on or after 1 July 2019.\n• Full-time equivalent: Working the standard full-time days/hours for that industry in a week (e.g. 5 days / 35–38h) counts as 7 calendar days.\n• Paid work & payslips: All specified work must be paid in accordance with Australian workplace law (except approved Bushfire/Flood recovery volunteer work).\n• Mining Note: Mining is ONLY eligible for Subclass 417, NOT Subclass 462.';
    }
  }

  static String getOpenOfficialPageLabel(String subclass, String lang) {
    switch (lang) {
      case 'fr':
        return 'Consulter le site officiel Home Affairs (Specified $subclass Work)';
      case 'it':
        return 'Apri pagina ufficiale Home Affairs (Specified $subclass Work)';
      case 'zh':
        return '在澳洲移民局官网打开指定工作说明页面（$subclass）';
      case 'es':
        return 'Abrir Web Oficial de Home Affairs (Specified $subclass Work)';
      default:
        return 'Open Official Home Affairs Specified $subclass Work Page';
    }
  }

  static String getStateFullName(String code, String lang) {
    final c = code.toUpperCase();
    switch (lang) {
      case 'fr':
        switch (c) {
          case 'NSW': return 'Nouvelle-Galles du Sud (NSW)';
          case 'WA': return 'Australie-Occidentale (WA)';
          case 'SA': return 'Australie-Méridionale (SA)';
          case 'NT': return 'Territoire du Nord (NT)';
          case 'ACT': return 'Territoire de la capitale (ACT)';
          case 'QLD': return 'Queensland (QLD)';
          case 'VIC': return 'Victoria (VIC)';
          case 'TAS': return 'Tasmanie (TAS)';
          default: return c;
        }
      case 'it':
        switch (c) {
          case 'NSW': return 'Nuovo Galles del Sud (NSW)';
          case 'WA': return 'Australia Occidentale (WA)';
          case 'SA': return 'Australia Meridionale (SA)';
          case 'NT': return 'Territorio del Nord (NT)';
          case 'ACT': return 'Territorio della Capitale (ACT)';
          case 'QLD': return 'Queensland (QLD)';
          case 'VIC': return 'Victoria (VIC)';
          case 'TAS': return 'Tasmania (TAS)';
          default: return c;
        }
      case 'zh':
        switch (c) {
          case 'NSW': return '新南威尔士州 (NSW)';
          case 'WA': return '西澳大利亚州 (WA)';
          case 'SA': return '南澳大利亚州 (SA)';
          case 'NT': return '北领地 (NT)';
          case 'ACT': return '首都领地 (ACT)';
          case 'QLD': return '昆士兰州 (QLD)';
          case 'VIC': return '维多利亚州 (VIC)';
          case 'TAS': return '塔斯马尼亚州 (TAS)';
          default: return c;
        }
      case 'es':
        switch (c) {
          case 'NSW': return 'Nueva Gales del Sur (NSW)';
          case 'WA': return 'Australia Occidental (WA)';
          case 'SA': return 'Australia Meridional (SA)';
          case 'NT': return 'Territorio del Norte (NT)';
          case 'ACT': return 'Territorio Capital (ACT)';
          case 'QLD': return 'Queensland (QLD)';
          case 'VIC': return 'Victoria (VIC)';
          case 'TAS': return 'Tasmania (TAS)';
          default: return c;
        }
      default:
        switch (c) {
          case 'NSW': return 'New South Wales (NSW)';
          case 'WA': return 'Western Australia (WA)';
          case 'SA': return 'South Australia (SA)';
          case 'NT': return 'Northern Territory (NT)';
          case 'ACT': return 'Australian Capital Territory (ACT)';
          case 'QLD': return 'Queensland (QLD)';
          case 'VIC': return 'Victoria (VIC)';
          case 'TAS': return 'Tasmania (TAS)';
          default: return c;
        }
    }
  }

  static String getSearchPlaceholder(String lang) {
    switch (lang) {
      case 'fr':
        return '4870 (ex : Cairns, Byron Bay, Darwin...)';
      case 'it':
        return '4870 (es: Cairns, Byron Bay, Darwin...)';
      case 'zh':
        return '4870（例如：Cairns, Byron Bay, Darwin...）';
      case 'es':
        return '4870 (ej: Cairns, Byron Bay, Darwin...)';
      default:
        return '4870 (e.g. Cairns, Byron Bay, Darwin...)';
    }
  }

  static String getSearchButton(String lang) {
    switch (lang) {
      case 'fr':
        return 'Vérifier';
      case 'it':
        return 'Verifica';
      case 'zh':
        return '查询';
      case 'es':
        return 'Validar';
      default:
        return 'Check';
    }
  }

  static String getNoResultSearchHelper(String lang) {
    switch (lang) {
      case 'fr':
        return 'Entrez un code postal à 4 chiffres ou touchez la carte pour vérifier les règles officielles.';
      case 'it':
        return 'Inserisci un CAP a 4 cifre o tocca la mappa per verificare le regole ufficiali Home Affairs.';
      case 'zh':
        return '输入4位澳洲邮编，或轻触地图即可核对移民局官方指定行业规则。';
      case 'es':
        return 'Introduce un código postal de 4 dígitos o pulsa en el mapa para validar la normativa de Home Affairs.';
      default:
        return 'Enter any 4-digit postcode or tap the map to check official Home Affairs rules.';
    }
  }

  static String getZoneLabel(String lang) {
    switch (lang) {
      case 'fr': return 'Zone';
      case 'it': return 'Zona';
      case 'zh': return '所属区域';
      case 'es': return 'Zona';
      default: return 'Zone';
    }
  }

  static String getZoneName(String zone, String lang) {
    switch (zone) {
      case 'northern':
        switch (lang) {
          case 'fr': return 'Australie du Nord (Tableau 3)';
          case 'it': return 'Nord dell\'Australia (Tabella 3)';
          case 'zh': return '澳洲北部地区（附表3）';
          case 'es': return 'Norte de Australia (Tabla 3)';
          default: return 'Northern Australia (Table 3)';
        }
      case 'remote':
        switch (lang) {
          case 'fr': return 'Éloigné / Très Éloigné (Tableaux 1 & 2)';
          case 'it': return 'Remoto / Molto Remoto (Tabelle 1 & 2)';
          case 'zh': return '偏远与极度偏远地区（附表1与2）';
          case 'es': return 'Remota / Muy Remota (Tablas 1 y 2)';
          default: return 'Remote / Very Remote (Tables 1 & 2)';
        }
      case 'regional':
        switch (lang) {
          case 'fr': return 'Australie Régionale (Tableau 4)';
          case 'it': return 'Australia Regionale (Tabella 4)';
          case 'zh': return '指定偏远地区（附表4）';
          case 'es': return 'Australia Regional (Tabla 4)';
          default: return 'Regional Australia (Table 4)';
        }
      default:
        switch (lang) {
          case 'fr': return 'Zone Métropolitaine / Non-Régionale';
          case 'it': return 'Area Metropolitana / Non Regionale';
          case 'zh': return '大都市区 / 非偏远地区';
          case 'es': return 'Área Metropolitana / No Regional';
          default: return 'Metropolitan / Non-Regional';
        }
    }
  }

  static String getRegionalBadge(bool isRegional, String lang) {
    switch (lang) {
      case 'fr':
        return isRegional ? '✓ RÉGIONAL VALIDE' : '✕ MÉTROPOLITAIN';
      case 'it':
        return isRegional ? '✓ REGIONALE VALIDO' : '✕ METROPOLITANO';
      case 'zh':
        return isRegional ? '✓ 符合偏远地区资格' : '✕ 都会区（不符）';
      case 'es':
        return isRegional ? '✓ REGIONAL VÁLIDO' : '✕ METRO';
      default:
        return isRegional ? '✓ REGIONAL' : '✕ METRO';
    }
  }

  static String getPostcodeEligibilityDescription(bool isRegional, bool hasDisasterSpecial, String lang) {
    if (isRegional) {
      switch (lang) {
        case 'fr':
          return 'Code postal régional officiel selon les tableaux Home Affairs. Les jours travaillés dans les secteurs valides comptent pour vos 88 ou 179 jours.';
        case 'it':
          return 'CAP regionale ufficiale secondo le tabelle Home Affairs. I giorni lavorati nei settori validi contano per i tuoi 88 o 179 giorni.';
        case 'zh':
          return '属于澳洲移民局官方认可的偏远地区邮编。在有效行业内工作的天数均可计入88天或179天续签要求。';
        case 'es':
          return 'Código postal regional oficial de Home Affairs. Los días trabajados en las industrias marcadas en verde computan para tus 88 o 179 días.';
        default:
          return 'Official eligible regional postcode under Home Affairs Specified Work tables. Days worked in valid industries count towards your 88 or 179 days.';
      }
    } else if (hasDisasterSpecial) {
      switch (lang) {
        case 'fr':
          return 'Code métropolitain : agriculture, hôtellerie ou construction ordinaires NE comptent PAS ici, SAUF récupération déclarée incendies/inondations (Tableaux 5/6) ou santé COVID-19.';
        case 'it':
          return 'CAP metropolitano: agricoltura, edilizia o ospitalità ordinarie NON contano qui, ECCETTO recupero incendi/alluvioni ufficiali (Tabelle 5/6) o sanità COVID-19.';
        case 'zh':
          return '都会区邮编：常规农业、建筑或餐饮酒店工时在此处不符合续签条件，除非属于官方宣告的林火/洪涝灾害恢复（附表5/6）或COVID-19医疗医疗工作。';
        case 'es':
          return 'Código metropolitano: agricultura, obra u hostelería ordinaria NO computan aquí, EXCEPTO recuperación oficial de desastres/incendios (Tablas 5/6) o salud COVID-19.';
        default:
          return 'Metropolitan postcode: regular farming/hospitality/construction DOES NOT count here, EXCEPT declared Disaster/Bushfire Recovery (Tables 5/6) or COVID-19 Healthcare.';
      }
    } else {
      switch (lang) {
        case 'fr':
          return 'Zone métropolitaine : le travail ordinaire ici NE compte PAS pour renouveler vos 88/179 jours (seul le travail médical critique COVID-19 s\'applique à l\'échelle nationale).';
        case 'it':
          return 'Area metropolitana: il lavoro ordinario qui NON conta per rinnovare i tuoi 88/179 giorni (solo il lavoro medico critico COVID-19 si applica a livello nazionale).';
        case 'zh':
          return '都会区：在此处从事的常规工作不能用于88/179天续签（仅特例关键COVID-19医疗医护工作适用于全澳范围）。';
        case 'es':
          return 'Zona metropolitana: el trabajo ordinario aquí NO computa para renovar tus 88/179 días (únicamente salud crítica COVID-19 aplica en todo el país).';
        default:
          return 'Metropolitan area: standard work performed here DOES NOT count towards 88/179 day visa renewal (only critical COVID-19 medical work applies nationwide).';
      }
    }
  }

  static String getSearchChipLabel(String id, String lang) {
    switch (id) {
      case 'agriculture':
        switch (lang) {
          case 'fr': return 'Agriculture';
          case 'it': return 'Agricoltura';
          case 'zh': return '农牧业';
          case 'es': return 'Agricultura';
          default: return 'Agriculture';
        }
      case 'construction':
        switch (lang) {
          case 'fr': return 'Construction';
          case 'it': return 'Costruzioni';
          case 'zh': return '建筑施工';
          case 'es': return 'Construcción';
          default: return 'Construction';
        }
      case 'hospitality':
        switch (lang) {
          case 'fr': return 'Hôtellerie & Tourisme';
          case 'it': return 'Ospitalità & Turismo';
          case 'zh': return '酒店餐饮与旅游';
          case 'es': return 'Hostelería y Turismo';
          default: return 'Hospitality & Tourism';
        }
      case 'fishing_forestry':
        switch (lang) {
          case 'fr': return 'Pêche & Sylviculture';
          case 'it': return 'Pesca & Silvicoltura';
          case 'zh': return '渔业与林业';
          case 'es': return 'Pesca y Silvicultura';
          default: return 'Fishing & Forestry';
        }
      case 'bushfire':
        switch (lang) {
          case 'fr': return 'Incendies (Tableau 5)';
          case 'it': return 'Incendi (Tabella 5)';
          case 'zh': return '山火重建（附表5）';
          case 'es': return 'Incendios (Tabla 5)';
          default: return 'Bushfire (Table 5)';
        }
      case 'flood':
        switch (lang) {
          case 'fr': return 'Inondations (Tableau 6)';
          case 'it': return 'Alluvioni (Tabella 6)';
          case 'zh': return '洪灾救援（附表6）';
          case 'es': return 'Inundaciones (Tabla 6)';
          default: return 'Flood/Disaster (Table 6)';
        }
      default:
        return id;
    }
  }

  static String? getHospitalityChipNote(String subclass, bool isNorthern, bool isRemote, String lang) {
    if (subclass == '417') {
      switch (lang) {
        case 'fr': return '462 uniquement';
        case 'it': return 'Solo 462';
        case 'zh': return '仅限462';
        case 'es': return 'Solo 462';
        default: return '462 only';
      }
    }
    if (!isNorthern && !isRemote) {
      switch (lang) {
        case 'fr': return 'Nord/Éloigné uniquement';
        case 'it': return 'Solo Nord/Remoto';
        case 'zh': return '仅限北部/偏僻地区';
        case 'es': return 'Solo Norte/Remoto';
        default: return 'North/Remote only';
      }
    }
    return null;
  }

  static String? getFishingChipNote(String subclass, bool isNorthern, String lang) {
    if (subclass == '462' && !isNorthern) {
      switch (lang) {
        case 'fr': return 'Nord uniquement';
        case 'it': return 'Solo Nord';
        case 'zh': return '仅限北部';
        case 'es': return 'Solo Norte';
        default: return 'North only';
      }
    }
    return null;
  }

  // --- WORK LOG & TRACKER LOCALIZATION ---

  static String getTrackerTitle(int year, String lang) {
    if (year == 2) {
      switch (lang) {
        case 'fr': return '🗓️ Suivi des 88 Jours Régionaux (2e Année)';
        case 'it': return '🗓️ Registro 88 Giorni Regionali (2° Anno)';
        case 'zh': return '🗓️ 88天偏远地区工时记录（二签）';
        case 'es': return '🗓️ Registro de 88 Días Regionales (2º Año)';
        default: return '🗓️ 88 Days Regional Tracker (2nd Year)';
      }
    } else {
      switch (lang) {
        case 'fr': return '🗓️ Suivi des 179 Jours Régionaux (3e Année)';
        case 'it': return '🗓️ Registro 179 Giorni Regionali (3° Anno)';
        case 'zh': return '🗓️ 179天偏远地区工时记录（三签）';
        case 'es': return '🗓️ Registro de 179 Días Regionales (3r Año)';
        default: return '🗓️ 179 Days Regional Tracker (3rd Year)';
      }
    }
  }

  static String getYearSelectorTitle(int year, String lang) {
    if (year == 2) {
      switch (lang) {
        case 'fr': return 'Visa 2e Année';
        case 'it': return 'Visto 2° Anno';
        case 'zh': return '二签申请';
        case 'es': return '2º Año de Visa';
        default: return '2nd Year Visa';
      }
    } else {
      switch (lang) {
        case 'fr': return 'Visa 3e Année';
        case 'it': return 'Visto 3° Anno';
        case 'zh': return '三签申请';
        case 'es': return '3r Año de Visa';
        default: return '3rd Year Visa';
      }
    }
  }

  static String getYearSelectorSubtitle(int year, String lang) {
    if (year == 2) {
      switch (lang) {
        case 'fr': return 'Requis : 88 Jours';
        case 'it': return 'Requisito: 88 Giorni';
        case 'zh': return '法定要求：88天';
        case 'es': return 'Requisito: 88 Días';
        default: return '88 Days Requirement';
      }
    } else {
      switch (lang) {
        case 'fr': return 'Requis : 179 Jours (6 Mois)';
        case 'it': return 'Requisito: 179 Giorni (6 Mesi)';
        case 'zh': return '法定要求：179天（6个月）';
        case 'es': return 'Requisito: 179 Días (6 Meses)';
        default: return '179 Days (6 Months)';
      }
    }
  }

  static String getProgressTitle(bool isPremium, int year, String lang) {
    if (!isPremium) {
      if (year == 2) {
        switch (lang) {
          case 'fr': return 'Progression Essai Gratuit (Max 10 Jours)';
          case 'it': return 'Progresso Prova Gratuita (Limite 10 Giorni)';
          case 'zh': return '免费试用进度（上限10天）';
          case 'es': return 'Progreso Gratuito (Límite 10 Días)';
          default: return 'Free Trial Progress (10-Day Cap)';
        }
      } else {
        switch (lang) {
          case 'fr': return 'Essai 3e Année (Max 10 Jours)';
          case 'it': return 'Prova 3° Anno (Limite 10 Giorni)';
          case 'zh': return '三签试用进度（上限10天）';
          case 'es': return 'Prueba 3r Año (Límite 10 Días)';
          default: return '3rd Year Trial (10-Day Cap)';
        }
      }
    } else {
      if (year == 2) {
        switch (lang) {
          case 'fr': return 'Progression Visa 2e Année (88 Jours)';
          case 'it': return 'Progresso Visto 2° Anno (88 Giorni)';
          case 'zh': return '二签工时进度（共88天）';
          case 'es': return 'Progreso 2º Año: 88 Días';
          default: return '2nd Year Visa Progress (88 Days)';
        }
      } else {
        switch (lang) {
          case 'fr': return 'Progression Visa 3e Année (179 Jours)';
          case 'it': return 'Progresso Visto 3° Anno (179 Giorni)';
          case 'zh': return '三签工时进度（共179天）';
          case 'es': return 'Progreso 3r Año: 179 Días';
          default: return '3rd Year Visa Progress (179 Days)';
        }
      }
    }
  }

  static String getDaysSuffix(String lang) {
    switch (lang) {
      case 'fr': return 'jours';
      case 'it': return 'giorni';
      case 'zh': return '天';
      case 'es': return 'días';
      default: return 'days';
    }
  }

  static String getProgressStatusMessage(int totalDays, int targetRequirement, bool isPremium, int year, String lang) {
    if (!isPremium) {
      if (totalDays >= 10) {
        switch (lang) {
          case 'fr':
            return '🔒 Limite gratuite de 10 jours atteinte ! Débloquez les $targetRequirement jours avec Premium.';
          case 'it':
            return '🔒 Limite gratuito di 10 giorni raggiunto! Sblocca tutti i $targetRequirement giorni con Premium.';
          case 'zh':
            return '🔒 免费试用10天上限已满！升级至高级版解锁完整的 $targetRequirement 天记录与验证。';
          case 'es':
            return '🔒 ¡Límite gratuito de 10 días alcanzado! Desbloquea los $targetRequirement días con Premium.';
          default:
            return '🔒 Free trial limit reached! Unlock the complete $targetRequirement days with Premium.';
        }
      } else {
        final remaining = 10 - totalDays;
        switch (lang) {
          case 'fr':
            return 'Il vous reste $remaining jours d\'essai gratuit à enregistrer.';
          case 'it':
            return 'Ti restano $remaining giorni di prova gratuita da registrare.';
          case 'zh':
            return '剩余 $remaining 天免费试用工时可记录。';
          case 'es':
            return 'Te quedan $remaining días de prueba gratuita por registrar.';
          default:
            return '$remaining free trial days remaining to log.';
        }
      }
    } else {
      if (totalDays >= targetRequirement) {
        if (year == 2) {
          switch (lang) {
            case 'fr': return '🎉 Objectif atteint ! Prêt à déposer votre visa 2e année.';
            case 'it': return '🎉 Obiettivo raggiunto! Pronto a richiedere il 2° anno.';
            case 'zh': return '🎉 目标已达成！已备齐申请二签所需的全部工时。';
            case 'es': return '🎉 ¡Meta alcanzada! Listo para solicitar tu 2º año.';
            default: return '🎉 Goal reached! Ready to lodge your 2nd year visa.';
          }
        } else {
          switch (lang) {
            case 'fr': return '🎉 Objectif atteint ! Prêt à déposer votre visa 3e année.';
            case 'it': return '🎉 Obiettivo raggiunto! Pronto a richiedere il 3° anno.';
            case 'zh': return '🎉 目标已达成！已备齐申请三签所需的全部工时。';
            case 'es': return '🎉 ¡Meta alcanzada! Listo para solicitar tu 3r año.';
            default: return '🎉 Goal reached! Ready to lodge your 3rd year visa.';
          }
        }
      } else {
        final remaining = targetRequirement - totalDays;
        switch (lang) {
          case 'fr': return '$remaining jours restants pour compléter.';
          case 'it': return 'Mancano $remaining giorni per completare.';
          case 'zh': return '距离达标还需 $remaining 天合规工时。';
          case 'es': return 'Faltan $remaining días para completar la extensión.';
          default: return '$remaining days remaining to complete.';
        }
      }
    }
  }

  static String getUnlockButton(String lang) {
    switch (lang) {
      case 'fr': return 'Débloquer';
      case 'it': return 'Sblocca';
      case 'zh': return '立即解锁';
      case 'es': return 'Desbloquear';
      default: return 'Unlock';
    }
  }

  static String getHorticultureLevel2Title(String lang) {
    switch (lang) {
      case 'fr': return '🌾 Horticulture Niveau 2 Débloqué (+90 jours)';
      case 'it': return '🌾 Livello 2 Orticoltura Sbloccato (+90 giorni)';
      case 'zh': return '🌾 园艺业 Modern Award 二级标准已解锁（累计90天+）';
      case 'es': return '🌾 Nivel 2 Horticultura Concedido (+90 días)';
      default: return '🌾 Horticulture Award Level 2 Unlocked (+90 days)';
    }
  }

  static String getHorticultureLevel2Desc(int agriDaysCounted, String lang) {
    switch (lang) {
      case 'fr':
        return 'Vous avez enregistré $agriDaysCounted jours dans l\'agriculture. Selon le Horticulture Award (MA000028), vous avez légalement droit au salaire de niveau 2 (+\$0.79 AUD/h au-dessus du salaire de base).';
      case 'it':
        return 'Hai registrato $agriDaysCounted giorni in agricoltura. In base all\'Horticulture Award (MA000028), hai legalmente diritto alla retribuzione di Livello 2 (+\$0.79 AUD/h rispetto alla paga base).';
      case 'zh':
        return '你在农业领域已累计记录 $agriDaysCounted 天。根据澳洲园艺裁决令（MA000028），你有权享受 Level 2 升级法定薪资（基准时薪额外+\$0.79 AUD/小时）。';
      case 'es':
        return 'Has acumulado $agriDaysCounted días en agricultura. Bajo el Horticulture Award (MA000028), tienes derecho legal al salario de Level 2 (+0.79 AUD/h respecto al salario base).';
      default:
        return 'You have logged $agriDaysCounted days in agriculture. Under the Horticulture Award (MA000028), you are legally entitled to Level 2 wages (+\$0.79 AUD/h above base rate).';
    }
  }

  static String getCondition8547Title(String lang) {
    switch (lang) {
      case 'fr': return '⏱️ Condition 8547 : Limite de 6 Mois Proche';
      case 'it': return '⏱️ Condizione 8547: Limite di 6 Mesi Vicino';
      case 'zh': return '⏱️ 8547工作条款：已接近6个月同一雇主雇佣上限';
      case 'es': return '⏱️ Condición 8547: Límite de 6 Meses Próximo';
      default: return '⏱️ Condition 8547: 6-Month Limit Near';
    }
  }

  static String getCondition8547Desc(String employer, String lang) {
    switch (lang) {
      case 'fr':
        return 'Vous approchez de 6 mois de travail avec $employer. Changez d\'employeur ou demandez une exemption officielle 8547 pour éviter l\'annulation de votre visa.';
      case 'it':
        return 'Ti stai avvicinando a 6 mesi di lavoro con $employer. Cambia datore o richiedi un\'esenzione ufficiale 8547 per evitare la cancellazione del visto.';
      case 'zh':
        return '你在 $employer 的工作时间已接近6个月上限。请注意更换雇主或申请8547条款豁免，避免违反签证条例导致签证被注销。';
      case 'es':
        return 'Te acercas a los 6 meses de trabajo con $employer. Cambia de empleador o solicita una exención oficial de la condición 8547 para evitar la cancelación de tu visado.';
      default:
        return 'You are approaching 6 months of work with $employer. Switch employers or request an official Condition 8547 exemption to avoid visa cancellation.';
    }
  }

  static String getAddJobButton(String lang) {
    switch (lang) {
      case 'fr': return 'Ajouter un Emploi Régional';
      case 'it': return 'Aggiungi Lavoro Regionale';
      case 'zh': return '添加偏远地区工作记录';
      case 'es': return 'Añadir Registro de Trabajo';
      default: return 'Add Regional Job Entry';
    }
  }

  static String getEmptyJobsMessage(String lang) {
    switch (lang) {
      case 'fr': return 'Aucun emploi enregistré pour l\'instant. Touchez ci-dessus pour ajouter le premier.';
      case 'it': return 'Nessun lavoro registrato finora. Tocca in alto per aggiungere il primo.';
      case 'zh': return '暂未添加任何工作记录。点击上方按钮开始录入第一份偏远地区工作。';
      case 'es': return 'Aún no has registrado ningún trabajo regional. Pulsa arriba para añadir el primero.';
      default: return 'No jobs recorded yet. Tap above to add your first job.';
    }
  }

  static String getHoursRiskBadge(String lang) {
    switch (lang) {
      case 'fr': return '⚠️ <7h/j (Risque)';
      case 'it': return '⚠️ <7h/g (Rischio)';
      case 'zh': return '⚠️ 日均工时不足7小时';
      case 'es': return '⚠️ <7h/d (Riesgo)';
      default: return '⚠️ <7h/day risk';
    }
  }

  static String getAbnIssueBadge(String lang) {
    switch (lang) {
      case 'fr': return '⚠️ Problème ABN ATO';
      case 'it': return '⚠️ Problema ABN ATO';
      case 'zh': return '⚠️ ABN税号校验异常';
      case 'es': return '⚠️ ABN irregular ATO';
      default: return '⚠️ ABN issue';
    }
  }

  static String getAtoVerifiedBadge(String lang) {
    switch (lang) {
      case 'fr': return '✓ Vérifié ATO';
      case 'it': return '✓ Verificato ATO';
      case 'zh': return '✓ 税局ATO核验通过';
      case 'es': return '✓ ABN Verificado ATO';
      default: return '✓ ATO Verified';
    }
  }

  static String getDaysHoursSummary(int days, double hours, double avgHours, String lang) {
    switch (lang) {
      case 'fr':
        return '$days jours • ${hours.toStringAsFixed(1)}h (${avgHours.toStringAsFixed(1)}h/j)';
      case 'it':
        return '$days giorni • ${hours.toStringAsFixed(1)}h (${avgHours.toStringAsFixed(1)}h/g)';
      case 'zh':
        return '$days天 • ${hours.toStringAsFixed(1)}工时 (日均${avgHours.toStringAsFixed(1)}h)';
      case 'es':
        return '$days días • ${hours.toStringAsFixed(1)}h (${avgHours.toStringAsFixed(1)}h/día)';
      default:
        return '$days days • ${hours.toStringAsFixed(1)}h (${avgHours.toStringAsFixed(1)}h/day)';
    }
  }

  static String getGrossPayLabel(String lang) {
    switch (lang) {
      case 'fr': return 'Brut';
      case 'it': return 'Lordo';
      case 'zh': return '税前';
      case 'es': return 'Bruto';
      default: return 'Gross';
    }
  }

  static String getFullTimeTag(String lang) {
    switch (lang) {
      case 'fr': return ' • Temps plein (7j)';
      case 'it': return ' • Tempo pieno (7g)';
      case 'zh': return ' • 全职（7天）';
      case 'es': return ' • Full-Time (7d)';
      default: return ' • Full-Time (7d)';
    }
  }

  static String getPieceworkTag(String lang) {
    switch (lang) {
      case 'fr': return ' • Au rendement/Piecework';
      case 'it': return ' • A cottimo/Piecework';
      case 'zh': return ' • 计件/Piecework';
      case 'es': return ' • Destajo/Piecework';
      default: return ' • Piecework';
    }
  }

  static String getExport1263Button(String lang) {
    switch (lang) {
      case 'fr': return 'Générer le Dossier Officiel Form 1263 (PDF)';
      case 'it': return 'Genera Dossier Ufficiale Modulo 1263 (PDF)';
      case 'zh': return '导出移民局官方1263表格证明（PDF）';
      case 'es': return 'Generar Formulario 1263 Oficial (PDF)';
      default: return 'Export Form 1263 PDF Dossier';
    }
  }

  static String getEmptyJobsSnackbar(String lang) {
    switch (lang) {
      case 'fr': return 'Ajoutez d\'abord au moins un emploi';
      case 'it': return 'Aggiungi prima almeno un lavoro';
      case 'zh': return '请先添加至少一条工作记录';
      case 'es': return 'Añade al menos un trabajo primero';
      default: return 'Add at least one job first';
    }
  }

  static String getPaywallTitle(int year, String lang) {
    if (year == 2) {
      switch (lang) {
        case 'fr': return 'Dossier Formulaire 1263 (2e Année)';
        case 'it': return 'Dossier Modulo 1263 (2° Anno)';
        case 'zh': return '1263表格官方防审查证明档案（二签）';
        case 'es': return 'Dossier Formulario 1263 (2º Año)';
        default: return 'Form 1263 Immigration Dossier (2nd Year)';
      }
    } else {
      switch (lang) {
        case 'fr': return 'Dossier Formulaire 1263 (3e Année)';
        case 'it': return 'Dossier Modulo 1263 (3° Anno)';
        case 'zh': return '1263表格官方防审查证明档案（三签）';
        case 'es': return 'Dossier Formulario 1263 (3r Año)';
        default: return 'Form 1263 Immigration Dossier (3rd Year)';
      }
    }
  }

  static String getPaywallBenefit(String lang) {
    switch (lang) {
      case 'fr':
        return 'Générez un dossier PDF du formulaire 1263 avec ABNs, heures et fiches de paie prêt pour ImmiAccount.';
      case 'it':
        return 'Genera un dossier PDF del modulo 1263 con ABN, ore e buste paga pronto per ImmiAccount.';
      case 'zh':
        return '一键生成符合移民局规范的1263表格PDF官方卷宗，含ABN核验、每日工时与工资单直接上传至ImmiAccount。';
      case 'es':
        return 'Genera el dossier en PDF del Formulario 1263 con ABNs, horas y recibos listo para adjuntar en ImmiAccount.';
      default:
        return 'Generate an audit-proof Form 1263 PDF dossier with ABNs, hours, and pay slips ready for ImmiAccount.';
    }
  }

  static String getAuditProtectionTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Protection Contre les Contrôles de l\'Immigration';
      case 'it': return 'Protezione Contro i Controlli dell\'Immigrazione';
      case 'zh': return '防移民局抽查合规审计保护';
      case 'es': return 'Protección Frente a Auditorías de Inmigración';
      default: return 'Immigration Audit Protection';
    }
  }

  static String getAuditProtectionDesc(String lang) {
    switch (lang) {
      case 'fr':
        return 'L\'Immigration contrôle ~23% des demandes de 2e année. Un ABN ou un code erroné entraîne un refus et la perte des frais de visa non remboursables de 650 \$ AUD.';
      case 'it':
        return 'L\'Immigrazione controlla ~23% delle domande di rinnovo. Un ABN o CAP errato comporta il rifiuto e la perdita della tassa governativa di 650 \$ AUD non rimborsabile.';
      case 'zh':
        return '移民局对二签申请的抽查率约为23%。错误或无效的ABN税号及邮编将导致签证直接被拒，且650澳元的签证申请费不予退还。';
      case 'es':
        return 'Inmigración audita ~23% de solicitudes de 2º año. Un ABN o código erróneo provoca denegación inmediata y la pérdida de la tasa oficial de \$650 AUD.';
      default:
        return 'Home Affairs audits ~23% of 2nd year applications. An invalid ABN or postcode leads to refusal and loss of the non-refundable \$650 AUD visa fee.';
    }
  }

  static String getAddJobModalTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Ajouter un Emploi Régional (Form 1263)';
      case 'it': return 'Aggiungi Lavoro Regionale (Modulo 1263)';
      case 'zh': return '添加偏远地区工作记录（Form 1263）';
      case 'es': return 'Añadir Empleo Regional (Form 1263)';
      default: return 'Add Regional Job (Form 1263)';
    }
  }

  static String getAddJobModalSubtitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Validation en direct du numéro ABN, code postal et heures pour éviter tout refus de visa.';
      case 'it':
        return 'Verifica in tempo reale di ABN, CAP e ore per prevenire il rifiuto del visto da parte di Home Affairs.';
      case 'zh':
        return '实时核验雇主ABN、工区邮编及工时合规性，杜绝因材料缺陷导致签证被拒。';
      case 'es':
        return 'Valida ABN, código postal y jornada laboral en tiempo real para evitar rechazos en Inmigración.';
      default:
        return 'Real-time ABN, postcode and hours validation to prevent Home Affairs visa refusals.';
    }
  }

  // --- FORM FIELD LABELS & VALIDATION ---

  static String getFieldLabel(String key, String lang) {
    switch (key) {
      case 'employer_name':
        switch (lang) {
          case 'fr': return 'Nom de l\'Entreprise ou de la Ferme *';
          case 'it': return 'Nome dell\'Azienda o Fattoria *';
          case 'zh': return '雇主/农场/公司法定名称 *';
          case 'es': return 'Nombre de la Empresa o Granja *';
          default: return 'Employer / Business Name *';
        }
      case 'abn':
        switch (lang) {
          case 'fr': return 'Numéro ABN de l\'employeur (11 chiffres) *';
          case 'it': return 'ABN del Datore di Lavoro (11 cifre) *';
          case 'zh': return '雇主ABN商业税号（11位） *';
          case 'es': return 'ABN del Empleador (11 dígitos) *';
          default: return 'Employer ABN (11 digits) *';
        }
      case 'postcode':
        switch (lang) {
          case 'fr': return 'Code Postal du Lieu de Travail (4 chiffres) *';
          case 'it': return 'CAP del Luogo di Lavoro (4 cifre) *';
          case 'zh': return '实际工作地点邮编（4位） *';
          case 'es': return 'Código Postal del Lugar de Trabajo (4 dígitos) *';
          default: return 'Work Site Postcode (4 digits) *';
        }
      case 'location':
        switch (lang) {
          case 'fr': return 'Localité / Ville / Exploitation *';
          case 'it': return 'Località / Comune / Fattoria *';
          case 'zh': return '工作地点/城镇/农场地址 *';
          case 'es': return 'Localidad / Pueblo / Granja *';
          default: return 'Work Site Location / Town / Property *';
        }
      case 'role':
        switch (lang) {
          case 'fr': return 'Poste ou Rôle Exercé *';
          case 'it': return 'Ruolo o Posizione Ricoperta *';
          case 'zh': return '担任职务/工种岗位 *';
          case 'es': return 'Puesto o Rol Desempeñado *';
          default: return 'Job Role / Position *';
        }
      case 'industry':
        switch (lang) {
          case 'fr': return 'Secteur / Industrie Approuvée (Home Affairs)';
          case 'it': return 'Settore Industriale Approvato (Home Affairs)';
          case 'zh': return '移民局官方认可行业分类';
          case 'es': return 'Sector / Industria Aprobada (Home Affairs)';
          default: return 'Approved Industry Sector (Home Affairs)';
        }
      case 'period':
        switch (lang) {
          case 'fr': return 'Période d\'Emploi';
          case 'it': return 'Periodo di Lavoro';
          case 'zh': return '受雇与工作周期';
          case 'es': return 'Periodo de Empleo';
          default: return 'Employment Period';
        }
      case 'start_date':
        switch (lang) {
          case 'fr': return 'Date Début';
          case 'it': return 'Data Inizio';
          case 'zh': return '起始日期';
          case 'es': return 'Fecha Inicio';
          default: return 'Start Date';
        }
      case 'end_date':
        switch (lang) {
          case 'fr': return 'Date Fin';
          case 'it': return 'Data Fin';
          case 'zh': return '结束日期';
          case 'es': return 'Fecha Fin';
          default: return 'End Date';
        }
      case 'days_counted':
        switch (lang) {
          case 'fr': return 'Jours Comptabilisés *';
          case 'it': return 'Giorni Conteggiati *';
          case 'zh': return '有效折算天数 *';
          case 'es': return 'Días Computados *';
          default: return 'Days Counted *';
        }
      case 'total_hours':
        switch (lang) {
          case 'fr': return 'Heures Totales Travaillées *';
          case 'it': return 'Ore Totali Lavorate *';
          case 'zh': return '累计实际工时 *';
          case 'es': return 'Horas Totales Trabajadas *';
          default: return 'Total Hours Worked *';
        }
      case 'gross_earnings':
        switch (lang) {
          case 'fr': return 'Salaire Brut Total (AUD) *';
          case 'it': return 'Stipendio Lordo Totale (AUD) *';
          case 'zh': return '税前总收入（AUD） *';
          case 'es': return 'Salario Bruto Total (AUD) *';
          default: return 'Gross Earnings Total (AUD) *';
        }
      case 'payslip_ref':
        switch (lang) {
          case 'fr': return 'Réf. Fiche de Paie / Reçu (Optionnel)';
          case 'it': return 'Rif. Busta Paga / Ricevuta (Opzionale)';
          case 'zh': return '工资单编号/凭证编号（选填）';
          case 'es': return 'Nº Recibo / Ref Nómina (Opcional)';
          default: return 'Payslip Ref / Receipt No. (Optional)';
        }
      case 'full_time_check':
        switch (lang) {
          case 'fr':
            return 'Semaine Complète Standard (compte pour 7 jours civils selon la règle Home Affairs)';
          case 'it':
            return 'Settimana Piena Standard (computa 7 giorni di calendario secondo Home Affairs)';
          case 'zh':
            return '法定全职周（依移民局规则，单周符合全职标准可按7个自然日申报）';
          case 'es':
            return 'Semana Completa Estándar (computa 7 días naturales por semana según regla Home Affairs)';
          default:
            return 'Standard Full-Time Week (counts as 7 calendar days per Home Affairs rule)';
        }
      case 'piecework_check':
        switch (lang) {
          case 'fr':
            return 'Accord de travail au rendement (Piecework) signé selon Fair Work';
          case 'it':
            return 'Accordo di lavoro a cottimo (Piecework) firmato secondo Fair Work';
          case 'zh':
            return '已签署符合 Fair Work 法定标准的计件协议（Piecework Agreement）';
          case 'es':
            return 'Acuerdo de Trabajo a Destajo / Piecework firmado según Fair Work';
          default:
            return 'Piecework Agreement signed in accordance with Fair Work';
        }
      case 'save_job':
        switch (lang) {
          case 'fr': return 'Enregistrer l\'Emploi Régional';
          case 'it': return 'Salva Lavoro Regionale';
          case 'zh': return '保存偏远地区工作记录';
          case 'es': return 'Guardar Registro de Trabajo';
          default: return 'Save Regional Job Entry';
        }
      case 'cancel':
        switch (lang) {
          case 'fr': return 'Annuler';
          case 'it': return 'Annulla';
          case 'zh': return '取消';
          case 'es': return 'Cancelar';
          default: return 'Cancel';
        }
      default:
        return key;
    }
  }

  static String getDefaultRole(String lang) {
    switch (lang) {
      case 'fr': return 'Cueilleur de fruits / Ouvrier agricole';
      case 'it': return 'Raccoglitore / Bracciante Agricolo';
      case 'zh': return '采摘工 / 农场普工';
      case 'es': return 'Recolector / Peón Agrícola';
      default: return 'Fruit Picker / Farm Hand';
    }
  }

  static String getValidationError(String key, String lang, {String? p1, String? p2}) {
    switch (key) {
      case 'name_required':
        switch (lang) {
          case 'fr': return 'Le nom de l\'entreprise est obligatoire.';
          case 'it': return 'Il nome del datore di lavoro è obbligatorio.';
          case 'zh': return '雇主/公司官方名称为必填项。';
          case 'es': return 'El nombre de la empresa es obligatorio.';
          default: return 'Employer / Business Name is required.';
        }
      case 'abn_required':
        switch (lang) {
          case 'fr': return 'L\'ABN est obligatoire pour le formulaire 1263.';
          case 'it': return 'L\'ABN è obbligatorio per il modulo 1263.';
          case 'zh': return '生成 1263 表格必须填写雇主ABN税号。';
          case 'es': return 'El ABN es obligatorio para el Formulario 1263.';
          default: return 'ABN is required for Form 1263 verification.';
        }
      case 'abn_11_digits':
        switch (lang) {
          case 'fr': return 'L\'ABN doit comporter exactement 11 chiffres (ex. : 51 824 753 556).';
          case 'it': return 'L\'ABN deve contenere esattamente 11 cifre (es.: 51 824 753 556).';
          case 'zh': return '澳洲ABN税号必须为精准的11位数字（如：51 824 753 556）。';
          case 'es': return 'El ABN debe tener exactamente 11 dígitos numéricos (ej: 51 824 753 556).';
          default: return 'ABN must contain exactly 11 digits (e.g., 51 824 753 556).';
        }
      case 'abn_checksum_invalid':
        switch (lang) {
          case 'fr': return 'ABN non valide : Échec de l\'algorithme de vérification de l\'ATO (numéro erroné).';
          case 'it': return 'ABN non valido: Non supera l\'algoritmo di verifica ufficiale ATO (numero errato).';
          case 'zh': return '无效ABN：未通过澳洲税务局ATO官方校验算法（可能为虚构或拼写错误）。';
          case 'es': return 'ABN Inválido: No cumple el algoritmo matemático de la ATO (ficticio o erróneo).';
          default: return 'Invalid ABN: Fails official ATO checksum algorithm (fictitious or mistyped number).';
        }
      case 'abn_cancelled':
        switch (lang) {
          case 'fr': return 'ABN annulé : L\'employeur est inactif sur le registre officiel. L\'Immigration rejettera ces jours.';
          case 'it': return 'ABN cancellato: Il datore risulta inattivo nel registro ufficiale ATO. Home Affairs rifiuterà queste giornate.';
          case 'zh': return 'ABN已注销：该雇主在官方注册中已失效。移民局将直接拒绝该段工时。';
          case 'es': return 'ABN Cancelado: El empleador está inactivo en el registro de la ATO. Inmigración denegará tu visa.';
          default: return 'ABN Cancelled: Employer is inactive on official registry. Home Affairs will reject these days.';
        }
      case 'postcode_invalid':
        switch (lang) {
          case 'fr': return 'Le code postal doit être composé de 4 chiffres australiens.';
          case 'it': return 'Il codice postale deve essere di 4 cifre australiane.';
          case 'zh': return '澳大利亚邮政编码必须为4位数字。';
          case 'es': return 'El código postal debe tener 4 dígitos australianos.';
          default: return 'Postcode must be a 4-digit Australian code.';
        }
      case 'postcode_not_regional':
        switch (lang) {
          case 'fr': return 'Le code postal $p1 N\'EST PAS régional sous LIN 22/050. L\'Immigration rejettera ces jours.';
          case 'it': return 'Il CAP $p1 NON è regionale ai sensi di LIN 22/050. Home Affairs rifiuterà queste giornate.';
          case 'zh': return '邮编 $p1 在移民局LIN 22/050法条中不属于偏远地区。移民局将拒绝认可。';
          case 'es': return 'El código postal $p1 NO figura en las zonas regionales de LIN 22/050. Inmigración rechazará estos días.';
          default: return 'Postcode $p1 is NOT regional under LIN 22/050. Home Affairs will reject these days.';
        }
      case 'industry_not_valid_here':
        switch (lang) {
          case 'fr': return 'Activité non valide pour le visa $p1 dans le code postal $p2.';
          case 'it': return 'Attività non valida per il visto $p1 nel CAP $p2.';
          case 'zh': return '该行业在邮编 $p2 下不符合 $p1 签证要求（例如酒店旅游业仅在澳洲北部有效）。';
          case 'es': return 'La industria no es computable en $p2 para tu visado $p1 (ej. hostelería solo computa en el Norte de Australia).';
          default: return 'Activity not valid for visa $p1 in $p2 (e.g. hospitality only counts in Northern Australia).';
        }
      case 'location_required':
        switch (lang) {
          case 'fr': return 'Le lieu ou la commune du lieu de travail est obligatoire.';
          case 'it': return 'La località o comune del cantiere/fattoria è obbligatoria.';
          case 'zh': return '农场或工作地所在城镇与地点为必填项。';
          case 'es': return 'La localidad o ubicación de la granja es obligatoria.';
          default: return 'Work site location / town is required.';
        }
      case 'role_required':
        switch (lang) {
          case 'fr': return 'Le poste ou le rôle exercé est obligatoire.';
          case 'it': return 'Il ruolo o la mansione ricoperta è obbligatoria.';
          case 'zh': return '所担任的具体职务或工作岗位为必填项。';
          case 'es': return 'El puesto o rol desempeñado es obligatorio.';
          default: return 'Job role / position is required.';
        }
      case 'dates_inverted':
        switch (lang) {
          case 'fr': return 'La date de début ne peut pas être postérieure à la date de fin.';
          case 'it': return 'La data di inizio non può essere successiva alla data di fine.';
          case 'zh': return '开始日期不能晚于结束日期。';
          case 'es': return 'La fecha de inicio no puede ser posterior a la de fin.';
          default: return 'Start date cannot be after end date.';
        }
      case 'dates_future':
        switch (lang) {
          case 'fr': return 'Les dates futures ne sont pas autorisées. Seuls les jours déjà travaillés comptent.';
          case 'it': return 'Non sono ammesse date future. Contano solo le giornate già completate.';
          case 'zh': return '不得填写未来日期。移民局仅认可已实际完成的工时。';
          case 'es': return 'No puedes indicar fechas futuras. Solo computan periodos ya trabajados.';
          default: return 'Future dates are not permitted. Only completed days count.';
        }
      case 'days_zero':
        switch (lang) {
          case 'fr': return 'Le nombre de jours doit être supérieur à 0.';
          case 'it': return 'I giorni conteggiati devono essere superiori a 0.';
          case 'zh': return '申报天数必须大于0。';
          case 'es': return 'Los días deben ser mayores a cero.';
          default: return 'Days counted must be greater than 0.';
        }
      case 'days_exceed_span':
        switch (lang) {
          case 'fr': return 'Incohérence : $p1 jours saisis pour une période de seulement $p2 jours civils.';
          case 'it': return 'Incongruenza: Inseriti $p1 giorni in un arco di soli $p2 giorni di calendario.';
          case 'zh': return '数据逻辑异常：在仅有 $p2 个自然日的时间跨度内填入了 $p1 个工作日。';
          case 'es': return 'Inconsistencia: Has puesto $p1 días trabajados en un periodo de solo $p2 días naturales.';
          default: return 'Inconsistency: $p1 days entered in a span of only $p2 calendar days.';
        }
      case 'trial_cap_exceeded':
        switch (lang) {
          case 'fr': return 'Limite gratuite : Dépasse l\'essai de 10 jours ($p1/10). Passez à Pro pour débloquer.';
          case 'it': return 'Limite gratuito: Supera la prova di 10 giorni ($p1/10). Passa a Pro per sbloccare.';
          case 'zh': return '免费版限制：超出10天试用上限（当前共$p1/10天）。升级至Pro即可解除限制。';
          case 'es': return 'Límite Free: Supera los 10 días de prueba ($p1/10). Requiere versión Pro.';
          default: return 'Free Limit: Exceeds 10-day trial ($p1/10). Upgrade to Pro to unlock.';
        }
      case 'hours_zero':
        switch (lang) {
          case 'fr': return 'Le total des heures doit être supérieur à 0.';
          case 'it': return 'Il totale delle ore deve essere maggiore di 0.';
          case 'zh': return '总工时必须大于0。';
          case 'es': return 'Las horas totales deben ser mayores a cero.';
          default: return 'Total hours must be greater than 0.';
        }
      default:
        return key;
    }
  }

  static String getHoursWarning(double avg, bool isExcess, String lang) {
    final formatted = avg.toStringAsFixed(1);
    if (!isExcess) {
      switch (lang) {
        case 'fr':
          return 'Risque Home Affairs (moyenne de ${formatted}h/j) : L\'Immigration exige un temps plein standard (7–7.6h/j). En dessous de 7h/j, le travail risque d\'être jugé à temps partiel et rejeté.';
        case 'it':
          return 'Rischio Home Affairs (media di ${formatted}h/giorno): L\'Immigrazione richiede tempo pieno standard (7–7.6h/g). Sotto le 7h/g rischia di essere considerato part-time e annullato.';
        case 'zh':
          return '移民局审核风险（日均 $formatted 小时）：移民局官方标准全职为每日 7–7.6 小时。日均低于 7 小时有被认定为兼职并遭驳回的风险。';
        case 'es':
          return 'Riesgo Home Affairs (media de ${formatted}h/día): Inmigración exige jornada completa estándar (7–7.6h/día o 35–38h/semana). Menos de 7h/día corre riesgo de ser catalogado como media jornada y anulado.';
        default:
          return 'Home Affairs Risk (${formatted}h/day average): Standard full-time is 7–7.6h/day (35–38h/week). Below 7h/day risks being deemed part-time and refused.';
      }
    } else {
      switch (lang) {
        case 'fr':
          return 'Heures excessives (${formatted}h/j) : Déclarer plus de 16h/jour déclenche des contrôles anti-fraude de l\'ATO et de l\'Immigration.';
        case 'it':
          return 'Ore inverosimili (${formatted}h/giorno): Dichiarare più di 16 ore al giorno attiva controlli anti-frode dell\'ATO e dell\'Immigrazione.';
        case 'zh':
          return '工时异常过高（日均 $formatted 小时）：申报超过16小时/天将极大触发澳洲税局ATO与移民局的反欺诈深度审计。';
        case 'es':
          return 'Horas Inverosímiles (${formatted}h/día): Declarar más de 16h/día dispara auditorías de la ATO e Inmigración por sospecha de fraude.';
        default:
          return 'Excessive Hours (${formatted}h/day): Declaring >16h daily triggers ATO anti-fraud audits.';
      }
    }
  }

  // --- DOSSIER EXPORT SHEET (FORM 1263 PDF) ---

  static String getDossierSheetTitle(int year, String lang) {
    if (year == 2) {
      switch (lang) {
        case 'fr': return 'Dossier Formulaire 1263 (2e Année)';
        case 'it': return 'Dossier Modulo 1263 (2° Anno)';
        case 'zh': return '1263表格申报卷宗（二签）';
        case 'es': return 'Dossier Formulario 1263 (2º Año)';
        default: return 'Form 1263 Dossier (2nd Year)';
      }
    } else {
      switch (lang) {
        case 'fr': return 'Dossier Formulaire 1263 (3e Année)';
        case 'it': return 'Dossier Modulo 1263 (3° Anno)';
        case 'zh': return '1263表格申报卷宗（三签）';
        case 'es': return 'Dossier Formulario 1263 (3r Año)';
        default: return 'Form 1263 Dossier (3rd Year)';
      }
    }
  }

  static String getDossierSheetSubtitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Entrez vos coordonnées officielles pour la vérification ImmiAccount';
      case 'it':
        return 'Inserisci i tuoi dati ufficiali per la verifica ImmiAccount';
      case 'zh':
        return '输入真实的官方申请人信息以供澳洲移民局核验';
      case 'es':
        return 'Introduce tus datos oficiales reales para la verificación en Inmigración';
      default:
        return 'Enter your official applicant details for ImmiAccount verification';
    }
  }

  static String getDossierFieldLabel(String key, String lang) {
    switch (key) {
      case 'full_name':
        switch (lang) {
          case 'fr': return 'Nom Légal Complet (selon le passeport) *';
          case 'it': return 'Nome Legale Completo (come da Passaporto) *';
          case 'zh': return '护照法定全名（必须与护照一致） *';
          case 'es': return 'Nombre Legal Completo (según Pasaporte) *';
          default: return 'Full Legal Name (as in Passport) *';
        }
      case 'passport':
        switch (lang) {
          case 'fr': return 'Numéro de Passeport *';
          case 'it': return 'Numero di Passaporto *';
          case 'zh': return '护照号码 *';
          case 'es': return 'Número de Pasaporte *';
          default: return 'Passport Number *';
        }
      case 'grant_number':
        switch (lang) {
          case 'fr': return 'N° d\'Attribution de Visa (Optionnel)';
          case 'it': return 'N. Concessione Visto (Opzionale)';
          case 'zh': return '签证批准准签号（Visa Grant No，选填）';
          case 'es': return 'Nº Concesión Visado (Opcional)';
          default: return 'Visa Grant No. (Optional)';
        }
      case 'phone':
        switch (lang) {
          case 'fr': return 'Téléphone Australien';
          case 'it': return 'Telefono Australiano';
          case 'zh': return '澳洲联系电话';
          case 'es': return 'Teléfono Australiano';
          default: return 'Australian Phone';
        }
      case 'email':
        switch (lang) {
          case 'fr': return 'Email de Contact (ImmiAccount)';
          case 'it': return 'Email di Contatto (ImmiAccount)';
          case 'zh': return '联系电子邮箱（与ImmiAccount一致）';
          case 'es': return 'Email de Contacto (ImmiAccount)';
          default: return 'Contact Email (ImmiAccount)';
        }
      case 'supervisor_signature_title':
        switch (lang) {
          case 'fr': return 'Signature du Superviseur / Employeur (Form 1263)';
          case 'it': return 'Firma del Supervisore / Datore di Lavoro (Modulo 1263)';
          case 'zh': return '主管/雇主电子签名（Form 1263）';
          case 'es': return 'Firma del Supervisor / Empleador (Form 1263)';
          default: return 'Supervisor / Employer Signature (Form 1263)';
        }
      case 'supervisor_signature_hint':
        switch (lang) {
          case 'fr':
            return 'Optionnel : Passez votre téléphone à votre superviseur le dernier jour pour signer sur l\'écran.';
          case 'it':
            return 'Opzionale: Passa il telefono al tuo supervisore l\'ultimo giorno per firmare sullo schermo.';
          case 'zh':
            return '选填：可在离职当天将手机递给农场主管或经理在屏幕上直接签名。';
          case 'es':
            return 'Opcional: Pásale el móvil a tu supervisor en tu último día de trabajo para firmar en pantalla.';
          default:
            return 'Optional: Hand your phone to your farm supervisor on your last day to sign on screen.';
        }
      case 'signed_badge':
        switch (lang) {
          case 'fr': return 'Signé sur l\'écran';
          case 'it': return 'Firmato sullo schermo';
          case 'zh': return '已在屏幕完成签名';
          case 'es': return 'Firmado en pantalla';
          default: return 'Signed on screen';
        }
      case 'sign_button':
        switch (lang) {
          case 'fr': return 'Signer avec le Doigt sur l\'Écran';
          case 'it': return 'Firma con il Dito sullo Schermo';
          case 'zh': return '在屏幕上手写电子签名';
          case 'es': return 'Firmar con el Dedo en Pantalla';
          default: return 'Sign with Finger on Screen';
        }
      case 'clear':
        switch (lang) {
          case 'fr': return 'Effacer';
          case 'it': return 'Cancella';
          case 'zh': return '清除';
          case 'es': return 'Borrar';
          default: return 'Clear';
        }
      case 'audit_proof_badge':
        switch (lang) {
          case 'fr':
            return '✓ Format Anti-Contrôle (<5 Mo) Prêt pour ImmiAccount : Codes LIN 22/050 conformes, ABNs vérifiés et taille optimale.';
          case 'it':
            return '✓ Formato a Prova di Audit (<5 MB) Pronto per ImmiAccount: CAP conformi a LIN 22/050, ABN verificati e peso ottimale.';
          case 'zh':
            return '✓ 官方防抽查合规格式（<5 MB 直接上传）：严格符合LIN 22/050法规邮编，税号真实核验，文件体积专为ImmiAccount优化。';
          case 'es':
            return '✓ Formato Blindado (<5 MB): Códigos LIN 22/050 conformes, ABNs verificados y peso óptimo para adjuntar en ImmiAccount.';
          default:
            return '✓ Audit-Proof & <5 MB ImmiAccount Ready: Validated LIN 22/050 postcodes, official ABNs and zero mock data.';
        }
      case 'generate_pdf':
        switch (lang) {
          case 'fr': return 'Générer le PDF Officiel';
          case 'it': return 'Genera PDF Ufficiale';
          case 'zh': return '立即生成官方PDF';
          case 'es': return 'Generar PDF Oficial';
          default: return 'Generate Official PDF';
        }
      default:
        return key;
    }
  }

  static String getDiscrepancyNote(String lang) {
    switch (lang) {
      case 'fr':
        return 'Le demandeur a effectué tout le travail spécifié physiquement sur site dans des codes postaux régionaux éligibles en vertu de l\'instrument LIN 22/050. Lorsque le siège social ou l\'entité de paie de l\'employeur est enregistré à une adresse métropolitaine, toutes les tâches pratiques ont été exécutées sur le site régional spécifié.';
      case 'it':
        return 'Il richiedente ha svolto tutto il lavoro specificato fisicamente sul posto all\'interno di CAP regionali idonei ai sensi dello strumento LIN 22/050. Laddove la sede legale o l\'entità di busta paga del datore sia registrata presso un indirizzo metropolitano, tutte le mansioni pratiche sono state svolte presso la sede regionale specificata.';
      case 'zh':
        return '申请人所记录的所有指定偏远地区工作，均在《移民法》LIN 22/050法条规定的合规偏远地区邮编内现场实际履行。若雇主总部或薪资开户主体注册在都会区商业地址，申请人的全部实际工作职责及工时均在经认证的偏远地区工作地点完成。';
      case 'es':
        return 'El solicitante realizó todo el trabajo especificado físicamente en códigos postales regionales elegibles bajo el Instrumento LIN 22/050. Cuando la sede fiscal de la empresa figure en una dirección metropolitana, todas las labores prácticas se desempeñaron en la ubicación regional certificada.';
      default:
        return 'Applicant performed all recorded specified work physically on-site within eligible regional postcodes under Migration Instrument LIN 22/050. Where an employer headquarters or payroll entity is registered under an administrative metropolitan ABN address, all practical duties and hours were performed at the specified regional farm/worksite location.';
    }
  }

  static String getSignatureDialogTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Signature du Superviseur';
      case 'it': return 'Firma del Supervisore';
      case 'zh': return '主管/雇主签名';
      case 'es': return 'Firma del Encargado / Granja';
      default: return 'Supervisor Signature';
    }
  }

  static String getSignatureDialogSubtitle(String lang) {
    switch (lang) {
      case 'fr': return 'Demandez à votre superviseur de signer dans l\'encadré';
      case 'it': return 'Chiedi al tuo supervisore di firmare all\'interno del riquadro';
      case 'zh': return '请让您的主管或农场负责人在框内手写签名';
      case 'es': return 'Pídele a tu supervisor que firme dentro del recuadro';
      default: return 'Ask your supervisor to sign inside the box';
    }
  }


  static String getAbnConnecting(String lang) {
    switch (lang) {
      case 'fr': return 'Connexion à abr.business.gov.au...';
      case 'it': return 'Connessione a abr.business.gov.au...';
      case 'zh': return '正在连接澳洲工商局 abr.business.gov.au...';
      case 'es': return 'Consultando abr.business.gov.au...';
      default: return 'Connecting to abr.business.gov.au...';
    }
  }

  static String getAbnChecksumFail(String lang) {
    switch (lang) {
      case 'fr': return 'L\'ABN échoue au test officiel ATO (numéro erroné).';
      case 'it': return 'L\'ABN non supera il test ufficiale ATO (errato o fittizio).';
      case 'zh': return 'ABN未通过税局官方校验（格式错误或虚构号码）。';
      case 'es': return 'ABN no supera el algoritmo ATO (ficticio o mal escrito).';
      default: return 'ABN fails official ATO Modulo-89 check (fake/mistyped).';
    }
  }

  static String getAbnCancelledTitle(String lang) {
    switch (lang) {
      case 'fr': return '🚨 ABN ANNULÉ dans le registre officiel';
      case 'it': return '🚨 ABN CANCELLATO nel registro ufficiale';
      case 'zh': return '🚨 该ABN在官方工商名录中已注销失效';
      case 'es': return '🚨 ABN CANCELADO en Registro Oficial';
      default: return '🚨 ABN CANCELLED in Official Registry';
    }
  }

  static String getAbnCancelledBody(String employer, String lang) {
    switch (lang) {
      case 'fr': return '$employer est ANNULÉ. L\'Immigration rejettera vos jours.';
      case 'it': return '$employer risulta CANCELLATO. Home Affairs rifiuterà i tuoi giorni.';
      case 'zh': return '$employer 已被官方注销。移民局将直接拒绝该段工作天数。';
      case 'es': return '$employer figura CANCELADO. Inmigración denegará tus 88 días.';
      default: return '$employer is CANCELLED. Immigration will reject your days.';
    }
  }

  static String getAbnChecksumValid(String lang) {
    switch (lang) {
      case 'fr': return '✓ Checksum ATO officiel valide (11 chiffres)';
      case 'it': return '✓ Checksum ufficiale ATO valido (11 cifre)';
      case 'zh': return '✓ ATO 官方算法校验通过（11位合规税号）';
      case 'es': return '✓ Checksum Oficial ATO Válido';
      default: return '✓ ATO Checksum Valid (11 digits)';
    }
  }

  static String getVerifyAbrButton(String lang) {
    switch (lang) {
      case 'fr': return 'Vérifier ABR';
      case 'it': return 'Verifica ABR';
      case 'zh': return '查验ABR';
      case 'es': return 'Verificar ABR';
      default: return 'Verify ABR';
    }
  }

  static String getVerifiedAbrApi(String lang) {
    switch (lang) {
      case 'fr': return '✓ Vérifié via l\'API gouvernementale ABR';
      case 'it': return '✓ Verificato tramite API governativa ABR';
      case 'zh': return '✓ 已通过澳洲联邦政府ABR官方API核验';
      case 'es': return '✓ Verificado en Registro Oficial ABR';
      default: return '✓ Verified by ABR Government API';
    }
  }

  static String getOfficialFileButton(String lang) {
    switch (lang) {
      case 'fr': return 'Fiche Officielle';
      case 'it': return 'Scheda Ufficiale';
      case 'zh': return '官方档案';
      case 'es': return 'Ficha Oficial';
      default: return 'Official File';
    }
  }

  static String getEligibleZoneTag(String location, String state, String lang) {
    switch (lang) {
      case 'fr': return '📍 $location ($state) - Zone éligible LIN 22/050';
      case 'it': return '📍 $location ($state) - Zona idonea LIN 22/050';
      case 'zh': return '📍 $location ($state) - 符合 LIN 22/050 法案偏远地区';
      case 'es': return '📍 $location ($state) - Zona elegible LIN 22/050';
      default: return '📍 $location ($state) - LIN 22/050 Eligible Area';
    }
  }

  static String getAverageBenchmarkText(double avgHours, double estGross, String lang) {
    final h = avgHours.toStringAsFixed(1);
    final g = estGross.toStringAsFixed(0);
    switch (lang) {
      case 'fr':
        return 'Moyenne : ${h}h/j • Référence légale Fair Work (~33.05/h) : \$$g AUD';
      case 'it':
        return 'Media: ${h}h/g • Riferimento legale Fair Work (~33.05/h): \$$g AUD';
      case 'zh':
        return '日均工时：${h}h/天 • Fair Work 法定薪资基准 (~33.05/h)：\$$g AUD';
      case 'es':
        return 'Media: ${h}h/día • Referencia legal Fair Work (~33.05/h): \$$g AUD';
      default:
        return 'Average: ${h}h/day • Fair Work benchmark (~33.05/h): \$$g AUD';
    }
  }

  static String getFullTimeRuleTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Règle semaine temps plein (5 jours = 7 jours comptés)';
      case 'it': return 'Regola settimana a tempo pieno (5 giorni = 7 giorni)';
      case 'zh': return '法定全职周规则（工作5天可按7个自然日申报）';
      case 'es': return 'Jornada Semanal Completa (5 días = 7 días computables)';
      default: return 'Full-Time Weekly Rule (5 days = 7 days count)';
    }
  }

  static String getFullTimeRuleSubtitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Selon LIN 22/050, travailler >=35h en 5 jours permet de compter les 7 jours de la semaine.';
      case 'it':
        return 'Secondo LIN 22/050, lavorare >=35 ore in 5 giorni consente di conteggiare tutti i 7 giorni.';
      case 'zh':
        return '根据移民法 LIN 22/050，若5天内工作达到35小时以上，可合法申报单周整7个自然日。';
      case 'es':
        return 'Según LIN 22/050, trabajar >=35h en 5 días permite computar los 7 días de la semana completa.';
      default:
        return 'Under LIN 22/050, working >=35h in 5 days allows counting all 7 days of the week.';
    }
  }

  static String getPieceworkRuleTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Accord de travail au rendement signé (Piecework Agreement)';
      case 'it': return 'Contratto a cottimo firmato (Piecework Agreement)';
      case 'zh': return '已签署合法计件协议（Piecework Agreement）';
      case 'es': return 'Contrato a Destajo Firmado (Piecework Agreement)';
      default: return 'Signed Piecework Agreement';
    }
  }

  static String getPieceworkRuleSubtitle(String lang) {
    switch (lang) {
      case 'fr':
        return 'Exigé par Fair Work pour les emplois à la pièce pour garantir le salaire minimum légal.';
      case 'it':
        return 'Richiesto da Fair Work per i lavori a cottimo per certificare la paga minima di base.';
      case 'zh':
        return '澳洲 Fair Work 官方要求采摘包装类计件工必须签署书面协议，以保障最低法定保底时薪。';
      case 'es':
        return 'Exigido por Fair Work en tareas a destajo para certificar el suelo legal salarial.';
      default:
        return 'Required by Fair Work for piece rate picking/packing jobs to ensure floor rate compliance.';
    }
  }

  static String getBlockingIssuesTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Erreurs de validation bloquantes :';
      case 'it': return 'Errori che comporteranno il rifiuto di Home Affairs:';
      case 'zh': return '检测到阻止提交的严重格式/合规错误：';
      case 'es': return 'Errores que Home Affairs Rechazará:';
      default: return 'Blocking Validation Issues Detected:';
    }
  }

  static String getAuditWarningTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Avertissement de contrôle de l\'Immigration :';
      case 'it': return 'Avviso di rischio di audit dell\'Immigrazione:';
      case 'zh': return '移民局合规审计风险提示：';
      case 'es': return 'Aviso de Riesgo ante Inmigración:';
      default: return 'Immigration Audit Warning:';
    }
  }

  static String getAuditProofEntryText(double avgHours, String lang) {
    final formatted = avgHours.toStringAsFixed(1);
    switch (lang) {
      case 'fr':
        return '✓ Saisie blindée : Code LIN 22/050 vérifié, ABN à 11 chiffres valide et horaire légal (~${formatted}h/j).';
      case 'it':
        return '✓ Registrazione blindata: CAP LIN 22/050 verificato, ABN valido di 11 cifre e orario legale (~${formatted}h/g).';
      case 'zh':
        return '✓ 官方防抽查合规条目：LIN 22/050 邮编验证有效、11位正式ABN税号及达标工时 (~${formatted}h/天)。';
      case 'es':
        return '✓ Registro Blindado: Código regional LIN 22/050 conforme, ABN válido de 11 dígitos y ratio horario legal (~${formatted}h/día).';
      default:
        return '✓ Audit-Proof Entry: Verified LIN 22/050 code, 11-digit ABN, and full-time compliant shift (~${formatted}h/day).';
    }
  }

  static String getSaveAndAuditButton(String lang) {
    switch (lang) {
      case 'fr': return 'Enregistrer & Valider';
      case 'it': return 'Salva & Verifica Lavoro';
      case 'zh': return '保存并进行合规审计';
      case 'es': return 'Guardar y Validar Empleo';
      default: return 'Save & Audit Job';
    }
  }

  static String getJobRecordedSnackbar(String lang) {
    switch (lang) {
      case 'fr': return '✓ Emploi régional enregistré et vérifié pour l\'audit !';
      case 'it': return '✓ Lavoro regionale registrato e verificato per l\'audit!';
      case 'zh': return '✓ 偏远地区工作记录已保存并完成防抽查审计验证！';
      case 'es': return '✓ Empleo regional registrado y validado para auditoría!';
      default: return '✓ Regional job entry recorded and audit-verified!';
    }
  }

  static String getTrialLimitReachedTitle(String lang) {
    switch (lang) {
      case 'fr': return 'Limite de 10 Jours Gratuits Atteinte';
      case 'it': return 'Limite Gratuito di 10 Giorni Raggiunto';
      case 'zh': return '已达到10天免费试用上限';
      case 'es': return 'Límite Gratuito de 10 Días';
      default: return '10-Day Free Limit Reached';
    }
  }

  static String getTrialLimitReachedBenefit(int year, String lang) {
    final target = year == 2 ? 88 : 179;
    switch (lang) {
      case 'fr':
        return 'L\'essai gratuit inclut jusqu\'à 10 jours. Passez à Premium pour enregistrer les $target jours et exporter le formulaire 1263.';
      case 'it':
        return 'La versione gratuita include fino a 10 giorni. Passa a Premium per registrare tutti i $target giorni ed esportare il modulo 1263.';
      case 'zh':
        return '免费版本最多支持记录10个工时。升级到高级版可记录完整的 $target 天工时并一键导出官方 1263 证明表格。';
      case 'es':
        return 'Superas los 10 días gratuitos. Pasa a Premium para registrar los $target días completos y generar el Formulario 1263.';
      default:
        return 'Free tier includes tracking up to 10 days. Upgrade to Premium to log all $target days and export Form 1263.';
    }
  }

}
