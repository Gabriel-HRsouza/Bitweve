import '../models/health_condition.dart';

class HealthCatalog {
  static const List<HealthCondition> conditions = [
    // Neurodesenvolvimento
    HealthCondition(
      id: 'adhd',
      name: 'TDAH (Atenção e Hiperatividade)',
      category: ConditionCategory.neurodevelopment,
      description: 'Diferença neurobiológica caracterizada por hiperfoco em temas de interesse, criatividade elevada e desafios na regulação executiva e foco rotineiro.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Apoio pedagógico, rotinas organizadas e eventual medicação estimulante.',
      medicationName: 'Cloridrato de Metilfenidato',
      monthlyCost: 120.0,
    ),
    HealthCondition(
      id: 'autism_spectrum',
      name: 'Transtorno do Espectro Autista (TEA)',
      category: ConditionCategory.neurodevelopment,
      description: 'Condição do neurodesenvolvimento com comunicação e processamento sensorial singulares, padrões focados de interesse e habilidades cognitivas profundas.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Adaptações sensoriais, respeito às rotinas e acompanhamento terapêutico multidisciplinar.',
      medicationName: null,
      monthlyCost: 200.0,
    ),
    HealthCondition(
      id: 'dyslexia',
      name: 'Dislexia',
      category: ConditionCategory.neurodevelopment,
      description: 'Dificuldade específica no reconhecimento preciso e fluente de palavras escritas e decodificação fonológica, com inteligência preservada.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Apoio fonoaudiológico e tecnologia assistiva de leitura.',
      medicationName: null,
      monthlyCost: 80.0,
    ),

    // Saúde Mental
    HealthCondition(
      id: 'depression',
      name: 'Depressão Clínica',
      category: ConditionCategory.mentalHealth,
      description: 'Quadro afetivo caracterizado por desânimo persistente, fadiga, anedonia e oscilações do sono e apetite.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Psicoterapia regular (TCC) e acompanhamento psiquiátrico.',
      medicationName: 'Inibidor Seletivo de Serotonina (ISRS)',
      monthlyCost: 150.0,
    ),
    HealthCondition(
      id: 'generalized_anxiety',
      name: 'Transtorno de Ansiedade Generalizada (TAG)',
      category: ConditionCategory.mentalHealth,
      description: 'Preocupação excessiva, tensão muscular contínua e hipervigilância diante de incertezas cotidianas.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Higiene do sono, psicoterapia, exercícios físicos e ansiolíticos quando indicados.',
      medicationName: 'Escitalopram / Ansiolítico',
      monthlyCost: 90.0,
    ),
    HealthCondition(
      id: 'bipolar_disorder',
      name: 'Transtorno Afetivo Bipolar',
      category: ConditionCategory.mentalHealth,
      description: 'Variações cíclicas de humor entre episódios de elevação de energia (hipomania/mania) e períodos de desânimo acentuado.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Estabilizadores de humor, rotina de sono estrita e psicoterapia de apoio.',
      medicationName: 'Carbonato de Lítio',
      monthlyCost: 180.0,
    ),
    HealthCondition(
      id: 'ocd',
      name: 'Transtorno Obsessivo-Compulsivo (TOC)',
      category: ConditionCategory.mentalHealth,
      description: 'Presença de pensamentos intrusivos recorrentes geradores de angústia e rituais comportamentais compensatórios.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Terapia de Exposição e Prevenção de Resposta (EPR).',
      medicationName: 'Sertralina',
      monthlyCost: 110.0,
    ),

    // Físicas Crônicas
    HealthCondition(
      id: 'type_1_diabetes',
      name: 'Diabetes Mellitus Tipo 1',
      category: ConditionCategory.chronicPhysical,
      description: 'Condição autoimune crônica na qual o pâncreas produz pouca ou nenhuma insulina, exigindo monitoramento glicêmico.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Administração diária de insulina basal-bolus e contagem de carboidratos.',
      medicationName: 'Insulina Glargina e Ultrarrápida',
      monthlyCost: 220.0,
    ),
    HealthCondition(
      id: 'asthma',
      name: 'Asma Brônquica',
      category: ConditionCategory.chronicPhysical,
      description: 'Inflamação crônica das vias aéreas que causa episódios de falta de ar, chiado no peito e tosse.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Inaladores de controle ambiental e medicação de alívio rápido.',
      medicationName: 'Budesonida com Formoterol',
      monthlyCost: 85.0,
    ),
    HealthCondition(
      id: 'hypertension',
      name: 'Hipertensão Arterial',
      category: ConditionCategory.chronicPhysical,
      description: 'Elevação sustentada da pressão arterial nos vasos sanguíneos, necessitando de controle para proteção cardiovascular.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Dieta hipossódica, atividade aeróbica e anti-hipertensivos.',
      medicationName: 'Losartana Potássica',
      monthlyCost: 45.0,
    ),
    HealthCondition(
      id: 'chronic_migraine',
      name: 'Enxaqueca Crônica',
      category: ConditionCategory.chronicPhysical,
      description: 'Crises cefálicas pulsáteis e incapacitantes, frequentemente acompanhadas de fotofobia, náuseas e aura sensorial.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Profilaxia com neuromoduladores e bloqueio de gatilhos alimentares.',
      medicationName: 'Topiramato / Triptanos',
      monthlyCost: 95.0,
    ),

    // Congênitas
    HealthCondition(
      id: 'down_syndrome',
      name: 'Síndrome de Down (Trissomia 21)',
      category: ConditionCategory.congenital,
      description: 'Condição genética congênita decorrente de uma terceira cópia do cromossomo 21, com traços físicos característicos e potencial cognitivo pleno sob estímulo precoce.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Fisioterapia motora, fonoaudiologia precoce e inclusão social plena.',
      medicationName: null,
      monthlyCost: 250.0,
    ),
    HealthCondition(
      id: 'congenital_heart_disease',
      name: 'Cardiopatia Congênita Leve',
      category: ConditionCategory.congenital,
      description: 'Pequena anomalia na estrutura cardíaca presente ao nascimento, requerendo vigilância com ecocardiograma.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Acompanhamento periódico com cardiologista pediátrico/adulto.',
      medicationName: null,
      monthlyCost: 150.0,
    ),
  ];

  /// Condições agudas (eventos de saúde). Curam-se com tratamento ou com o tempo.
  static const List<HealthCondition> acute = [
    HealthCondition(
      id: 'flu',
      name: 'Gripe Forte',
      category: ConditionCategory.acute,
      description: 'Febre, dor no corpo e muito cansaço.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Repouso, hidratação e antitérmico.',
      medicationName: 'Antitérmico',
      monthlyCost: 40.0,
    ),
    HealthCondition(
      id: 'fracture',
      name: 'Fratura no Braço',
      category: ConditionCategory.acute,
      description: 'Um osso quebrado após um acidente.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Imobilização com gesso e fisioterapia.',
      medicationName: 'Analgésico',
      monthlyCost: 120.0,
    ),
    HealthCondition(
      id: 'burnout',
      name: 'Síndrome de Burnout',
      category: ConditionCategory.mentalHealth,
      description: 'Esgotamento físico e mental causado por excesso de trabalho.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Afastamento, psicoterapia e mudança de rotina.',
      medicationName: null,
      monthlyCost: 160.0,
    ),
    HealthCondition(
      id: 'food_poisoning',
      name: 'Intoxicação Alimentar',
      category: ConditionCategory.acute,
      description: 'Algo que você comeu não caiu bem.',
      severity: ConditionSeverity.mild,
      supportNeeds: 'Soro e dieta leve.',
      medicationName: 'Soro oral',
      monthlyCost: 30.0,
    ),
    HealthCondition(
      id: 'back_pain',
      name: 'Hérnia de Disco',
      category: ConditionCategory.chronicPhysical,
      description: 'Dor lombar intensa que limita movimentos.',
      severity: ConditionSeverity.moderate,
      supportNeeds: 'Fisioterapia, RPG e fortalecimento muscular.',
      medicationName: 'Anti-inflamatório',
      monthlyCost: 140.0,
    ),
  ];

  static HealthCondition? getById(String id) {
    try {
      return [...conditions, ...acute].firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
