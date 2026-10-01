class MigrationData {
  // Official data from Department of Home Affairs
  // Extracted from: Migration and Temporary visa program quarterly report
  
  static const String sourceUrl = 'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-processing-times/quarterly-report';
  
  // No accents to avoid encoding bugs
  static const String currentProcessingTime = '< 1 dia';
  static const String approvalRate = '96.5%';
  
  // Data structured by year
  static const Map<String, List<Map<String, dynamic>>> lodgementsByYear = {
    '2023-2024': [
      {'quarter': 'Q1', 'lodged': 65147},
      {'quarter': 'Q2', 'lodged': 68059},
      {'quarter': 'Q3', 'lodged': 65479},
      {'quarter': 'Q4', 'lodged': 59610},
    ],
    '2024-2025': [
      {'quarter': 'Q1', 'lodged': 93952},
      {'quarter': 'Q2', 'lodged': 80110},
      {'quarter': 'Q3', 'lodged': 76409},
      {'quarter': 'Q4', 'lodged': 65434},
    ],
  };
}
