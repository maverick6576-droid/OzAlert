class MigrationData {
  // Datos oficiales del Department of Home Affairs
  // Extraídos de: Migration and Temporary visa program quarterly report
  
  static const String sourceUrl = 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-processing-times/quarterly-report';
  static const String currentProcessingTime = '< 1 día';
  static const String approvalRate = '86.5%';
  
  static const List<Map<String, dynamic>> quarterlyLodgements = [
    {'quarter': 'Q1', 'lodged': 93952},
    {'quarter': 'Q2', 'lodged': 80110},
    {'quarter': 'Q3', 'lodged': 76409},
    {'quarter': 'Q4', 'lodged': 65434},
  ];
}
