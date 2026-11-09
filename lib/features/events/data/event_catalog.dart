import '../models/life_event.dart';

EventChoice _c(
  String label,
  String text, [
  Map<String, dynamic> fx = const {},
  double? chance,
  String? fail,
  Map<String, dynamic> failFx = const {},
]) =>
    EventChoice(label: label, resultText: text, effects: fx, chance: chance, failText: fail, failEffects: failFx);

LifeEvent _e(
  String id,
  String cat,
  int minAge,
  int maxAge,
  String title,
  String desc,
  List<EventChoice> choices, {
  List<String> req = const [],
  String? target,
  String rarity = 'common',
  double weight = 1,
}) =>
    LifeEvent(
      id: id,
      category: cat,
      minAge: minAge,
      maxAge: maxAge,
      title: title,
      description: desc,
      choices: choices,
      requires: req,
      target: target,
      rarity: rarity,
      weight: weight,
    );

/// Eventos aleatórios com consequências reais. Complementa `assets/data/events.json`.
/// Use `{npc}` no texto para o nome do NPC alvo.
class EventCatalog {
  static final List<LifeEvent> events = [
    // ================================================================ INFÂNCIA / ESCOLA
    _e('kid_lost_tooth', 'infância', 5, 8, 'Dente de Leite', 'Seu primeiro dente de leite caiu! Dizem que a fada do dente paga bem.', [
      _c('Colocar embaixo do travesseiro', 'De manhã havia uma moeda brilhante no lugar do dente!', {'money': 10, 'happiness': 8}),
      _c('Guardar o dente numa caixinha', 'Você virou colecionador de dentes. Um pouco estranho, mas fofo.', {'smarts': 2, 'happiness': 3}),
    ]),
    _e('kid_bully', 'escola', 7, 14, 'Valentão no Recreio', 'Um colega maior está tomando o lanche das crianças menores, inclusive o seu.', [
      _c('Enfrentar o valentão', 'Você se impôs e ele recuou! Os colegas te admiram.', {'reputation': 8, 'happiness': 6, 'charisma': 3}, 0.55, 'Você levou um empurrão e um olho roxo. Doeu no orgulho.', {'health': -6, 'happiness': -8}),
      _c('Contar para a professora', 'A escola interveio e o valentão foi suspenso.', {'karma': 4, 'happiness': 3}),
      _c('Fazer amizade com ele', 'Surpresa: ele só precisava de um amigo. Vocês viraram parceiros!', {'addNpc': 'friend', 'karma': 6}, 0.5, 'Ele riu da sua cara e continuou te provocando.', {'happiness': -6, 'addNpc': 'rival'}),
    ]),
    _e('kid_science_fair', 'escola', 9, 17, 'Feira de Ciências', 'A escola está organizando a feira de ciências anual e você precisa de um projeto.', [
      _c('Vulcão de bicarbonato clássico', 'Funcionou como esperado. Nota razoável.', {'smarts': 3}),
      _c('Robô feito de sucata', 'Seu robô ganhou o 1º lugar e uma bolsa de R\$ 500!', {'smarts': 8, 'money': 500, 'reputation': 6}, 0.45, 'O robô pegou fogo no meio da apresentação. Pelo menos foi memorável.', {'smarts': 3, 'happiness': -5}),
      _c('Pedir para o {npc} fazer', '{npc} fez um projeto incrível, mas a professora desconfiou.', {'karma': -6, 'smarts': -2, 'rel': 4}),
    ], target: 'parent'),
    _e('kid_new_classmate', 'escola', 6, 17, 'Aluno Novo na Turma', 'Um aluno novo chegou de outra cidade e está sentado sozinho no intervalo.', [
      _c('Convidar para sentar com você', 'Vocês descobriram gostos em comum e viraram melhores amigos!', {'addNpc': 'friend', 'karma': 5, 'happiness': 6}),
      _c('Ignorar', 'Você seguiu com seu grupo de sempre.', {}),
    ]),
    _e('kid_report_card', 'escola', 7, 17, 'Boletim Escolar', 'O boletim chegou e {npc} quer conversar sobre suas notas.', [
      _c('Mostrar com orgulho', '{npc} ficou feliz com seu esforço e te deu um presente!', {'rel': 8, 'happiness': 6, 'money': 50}, 0.6, 'As notas não estavam boas. {npc} cortou seu videogame por um mês.', {'rel': -4, 'happiness': -6}),
      _c('Esconder o boletim', 'A escola ligou para casa. Você ficou de castigo!', {'rel': -10, 'happiness': -8, 'karma': -4}),
      _c('Prometer estudar mais', 'Você assumiu o compromisso e começou a estudar todos os dias.', {'smarts': 5, 'discipline': 6, 'rel': 5}),
    ], target: 'parent'),
    _e('kid_talent_show', 'escola', 8, 17, 'Show de Talentos', 'A escola vai fazer um show de talentos. Você vai se inscrever?', [
      _c('Cantar uma música', 'Você arrasou! O vídeo rodou o bairro todo.', {'charisma': 6, 'fame': 3, 'followers': 300, 'happiness': 10}, 0.55, 'Sua voz falhou no refrão. Risadas no auditório...', {'happiness': -10, 'reputation': -4}),
      _c('Apresentar mágica', 'Seu truque de cartas deixou todos boquiabertos!', {'charisma': 4, 'smarts': 2, 'happiness': 8}),
      _c('Assistir da plateia', 'Foi divertido torcer pelos colegas.', {'happiness': 2}),
    ]),
    _e('kid_pet_request', 'infância', 5, 12, 'Quero um Bichinho!', 'Você viu filhotes para adoção na feira e implorou para {npc} por um.', [
      _c('Insistir com carinho', '{npc} cedeu! Agora vocês têm um cachorrinho chamado Pipoca.', {'pet': 'Cachorro', 'happiness': 15, 'rel': 3}, 0.6, '{npc} disse que não dá para cuidar de um bicho agora.', {'happiness': -5}),
      _c('Aceitar o não', '{npc} ficou orgulhoso da sua maturidade.', {'rel': 6, 'karma': 3}),
    ], target: 'parent'),
    _e('teen_cheat_test', 'escola', 12, 18, 'Cola na Prova', 'Um colega oferece as respostas da prova de matemática por R\$ 50.', [
      _c('Comprar a cola', 'Você tirou 10! Ninguém percebeu.', {'money': -50, 'karma': -8}, 0.6, 'O professor pegou a cola. Zero na prova e suspensão!', {'money': -50, 'smarts': -3, 'reputation': -10, 'happiness': -10}),
      _c('Recusar e estudar', 'Você estudou a madrugada toda e tirou um 8 honesto.', {'smarts': 5, 'discipline': 4, 'karma': 5}),
      _c('Denunciar o esquema', 'O esquema foi desmantelado. Alguns colegas ficaram com raiva.', {'karma': 8, 'reputation': 4, 'addNpc': 'rival'}),
    ]),
    _e('teen_party', 'adolescência', 14, 19, 'Festa Sem Adultos', 'Rola uma festa na casa de um colega e os pais dele viajaram.', [
      _c('Ir e curtir', 'Foi a melhor noite do ano! Você conheceu muita gente.', {'happiness': 12, 'charisma': 4, 'addNpc': 'friend'}, 0.7, 'A polícia apareceu por causa do barulho. Seus pais foram te buscar...', {'happiness': -8, 'reputation': -6, 'relAll': -6}),
      _c('Ficar em casa', 'Você maratonou uma série e dormiu cedo.', {'health': 2, 'stress': -4}),
    ]),
    _e('teen_first_crush', 'amor', 13, 17, 'Primeira Paixão', 'Você não para de pensar em alguém da sua turma. O coração dispara quando passam perto.', [
      _c('Declarar-se com uma cartinha', 'A pessoa sorriu e disse que também gosta de você!', {'addNpc': 'partner', 'happiness': 18}, 0.45, 'A pessoa leu a carta em voz alta para a turma. Que vergonha!', {'happiness': -14, 'reputation': -5}),
      _c('Puxar assunto aos poucos', 'Vocês começaram a conversar todos os dias. Rolou uma paquera!', {'addNpc': 'crush', 'happiness': 8, 'charisma': 2}),
      _c('Guardar segredo', 'O sentimento foi passando com o tempo.', {'happiness': -2}),
    ], req: ['single']),
    _e('teen_part_time', 'carreira', 15, 17, 'Bico de Férias', 'A sorveteria do bairro precisa de ajudante nas férias.', [
      _c('Aceitar o trabalho', 'Você trabalhou duro e juntou um bom dinheiro!', {'money': 1500, 'discipline': 5, 'energy': -10}),
      _c('Curtir as férias', 'Praia, amigos e descanso total.', {'happiness': 10, 'stress': -10}),
    ]),
    _e('teen_vestibular', 'escola', 17, 17, 'Pressão do Vestibular', 'O vestibular está chegando e a ansiedade aumentou.', [
      _c('Cursinho intensivo (R\$ 3.000)', 'O cursinho te deu uma base fortíssima.', {'money': -3000, 'smarts': 10, 'stress': 10}),
      _c('Estudar sozinho com vídeos', 'Disciplina pura. Você aprendeu bastante.', {'smarts': 6, 'discipline': 6, 'stress': 6}),
      _c('Relaxar e confiar na sorte', 'Você ficou mais leve, mas menos preparado.', {'stress': -8, 'smarts': -2}),
    ]),
    // ================================================================ FAMÍLIA
    _e('fam_new_sibling', 'família', 1, 12, 'Notícia em Casa', 'Seus pais reuniram a família na sala: a família vai crescer!', [
      _c('Pular de alegria', 'Nasceu seu irmãozinho(a)! A casa ficou mais animada.', {'sibling': true, 'happiness': 10}),
      _c('Ficar com ciúmes', 'O bebê nasceu e você teve que dividir a atenção. Aos poucos se acostumou.', {'sibling': true, 'happiness': -4}),
    ], req: ['parents'], weight: 0.6),
    _e('fam_divorce', 'família', 3, 25, 'Pais em Crise', 'Seus pais andam brigando muito. Hoje anunciaram que vão se separar.', [
      _c('Tentar reconciliá-los', 'Você conversou com os dois e eles decidiram fazer terapia de casal!', {'relAll': 6, 'karma': 5}, 0.35, 'Não deu certo. Eles se separaram mesmo assim.', {'parentsDivorce': true, 'happiness': -14}),
      _c('Aceitar a decisão', 'Seus pais se separaram de forma amigável. Foi difícil, mas você entendeu.', {'parentsDivorce': true, 'happiness': -8}),
      _c('Ficar do lado de {npc}', 'Você escolheu um lado. {npc} ficou grato, mas o outro magoado.', {'parentsDivorce': true, 'rel': 10, 'happiness': -10}),
    ], req: ['parents'], target: 'parent', weight: 0.5),
    _e('fam_parent_reunion', 'família', 5, 40, 'Reaproximação Familiar', '{npc} te ligou depois de muito tempo querendo reatar os laços.', [
      _c('Dar uma nova chance', 'Vocês conversaram por horas e o vínculo renasceu.', {'rel': 25, 'happiness': 10, 'karma': 5}),
      _c('Manter distância', 'Você preferiu se proteger. Talvez um dia...', {'rel': -5}),
    ], target: 'family'),
    _e('fam_argument', 'família', 10, 60, 'Discussão em Família', 'O almoço de domingo virou uma discussão acalorada com {npc} sobre política.', [
      _c('Defender sua opinião', 'Você expôs seus argumentos com firmeza. O clima esfriou.', {'rel': -10, 'charisma': 2, 'stress': 4}),
      _c('Mudar de assunto', 'Você salvou o almoço com uma piada. Todos riram.', {'rel': 3, 'charisma': 2}),
      _c('Sair da mesa', 'Você foi embora irritado(a).', {'rel': -15, 'happiness': -5}),
    ], target: 'family'),
    _e('fam_move_city', 'família', 3, 16, 'Mudança de Cidade', 'Seus pais receberam uma proposta de emprego em outra cidade.', [
      _c('Animar-se com a aventura', 'Nova cidade, nova escola, novos amigos!', {'relocate': true, 'happiness': 5, 'charisma': 3}),
      _c('Protestar muito', 'A mudança aconteceu mesmo assim e você sentiu falta dos amigos.', {'relocate': true, 'happiness': -10}),
    ], req: ['parents'], weight: 0.5),
    _e('fam_grandparent_gift', 'família', 6, 30, 'Presente Inesperado', '{npc} apareceu com um envelope: "Guarde para o seu futuro".', [
      _c('Agradecer e guardar', 'Havia R\$ 2.000 no envelope!', {'money': 2000, 'rel': 8}),
      _c('Recusar educadamente', '{npc} insistiu e ficou emocionado com sua humildade.', {'money': 1000, 'rel': 12, 'karma': 4}),
    ], target: 'parent'),
    _e('fam_parent_sick', 'família', 18, 70, 'Doença na Família', '{npc} foi internado(a) e precisa de um tratamento caro.', [
      _c('Pagar o tratamento (R\$ 15.000)', '{npc} se recuperou totalmente graças a você.', {'money': -15000, 'rel': 30, 'karma': 10, 'happiness': 5}),
      _c('Visitar todos os dias', 'Sua presença foi o melhor remédio. {npc} melhorou aos poucos.', {'rel': 18, 'stress': 10, 'energy': -10}),
      _c('Estar ocupado demais', '{npc} ficou magoado com sua ausência.', {'rel': -20, 'karma': -8}),
    ], req: ['adult'], target: 'parent'),
    _e('fam_inheritance_fight', 'família', 25, 80, 'Briga por Herança', 'Um tio distante faleceu e a família está disputando a herança.', [
      _c('Entrar na disputa judicial', 'Você ganhou a causa e recebeu sua parte!', {'inheritance': [20000, 120000], 'stress': 12, 'relAll': -8}, 0.55, 'Você perdeu a causa e ainda pagou os advogados.', {'money': -8000, 'stress': 15}),
      _c('Abrir mão em nome da paz', 'A família ficou unida e grata pela sua atitude.', {'relAll': 10, 'karma': 10}),
    ], weight: 0.6),
    _e('fam_child_trouble', 'família', 25, 70, 'Problema na Escola', 'A escola ligou: {npc} se meteu numa briga.', [
      _c('Conversar com calma', '{npc} se abriu e contou que estava sofrendo bullying. Vocês resolveram juntos.', {'rel': 15, 'karma': 5}),
      _c('Colocar de castigo', '{npc} obedeceu, mas ficou distante.', {'rel': -8}),
    ], target: 'child'),
    _e('fam_child_wedding', 'família', 45, 90, 'Casamento de {npc}', '{npc} vai se casar e pediu ajuda com a festa.', [
      _c('Pagar a festa (R\$ 40.000)', 'Foi a festa mais linda da família!', {'money': -40000, 'rel': 25, 'happiness': 15}),
      _c('Ajudar a organizar', 'Você cuidou de cada detalhe com carinho.', {'rel': 15, 'happiness': 10, 'stress': 6}),
    ], target: 'child', weight: 0.5),
    // ================================================================ SOCIAL
    _e('soc_gossip', 'social', 12, 70, 'Fofoca Maldosa', 'Estão espalhando um boato falso sobre você.', [
      _c('Confrontar quem começou', 'A verdade veio à tona e sua reputação foi restaurada.', {'reputation': 6, 'addNpc': 'rival'}, 0.6, 'A discussão piorou tudo. O boato ficou ainda maior.', {'reputation': -8, 'stress': 8}),
      _c('Ignorar com elegância', 'O boato morreu sozinho em poucas semanas.', {'stress': 4}),
      _c('Postar uma resposta nas redes', 'Seu post viralizou e você ganhou seguidores!', {'followers': 1500, 'fame': 2, 'reputation': 2}),
    ]),
    _e('soc_party_invite', 'social', 18, 60, 'Convite VIP', 'Você foi convidado para uma festa exclusiva numa cobertura.', [
      _c('Ir e fazer networking', 'Você conheceu pessoas influentes e fez um contato valioso.', {'addNpc': 'friend', 'charisma': 4, 'reputation': 4, 'happiness': 8}),
      _c('Ir e curtir sem limites', 'Foi épico... até a ressaca no dia seguinte.', {'happiness': 12, 'health': -5, 'money': -400}),
      _c('Recusar', 'Você ficou em casa descansando.', {'energy': 10}),
    ]),
    _e('soc_friend_loan', 'social', 18, 80, 'Amigo em Apuros', '{npc} está passando por dificuldades e pediu R\$ 3.000 emprestados.', [
      _c('Emprestar o dinheiro', '{npc} te pagou de volta com juros e muita gratidão!', {'money': 500, 'rel': 20, 'karma': 6}, 0.6, '{npc} sumiu com o dinheiro. Amizade abalada.', {'money': -3000, 'rel': -25}),
      _c('Ajudar a montar um currículo', '{npc} conseguiu um emprego graças a você!', {'rel': 12, 'karma': 5}),
      _c('Dizer que não pode', '{npc} entendeu, mas ficou chateado.', {'rel': -8}),
    ], req: ['friends'], target: 'friend'),
    _e('soc_friend_moving', 'social', 10, 70, 'Despedida', '{npc} vai se mudar para outro país.', [
      _c('Organizar uma festa surpresa', 'Foi uma despedida emocionante. Vocês prometeram manter contato.', {'money': -300, 'rel': 15, 'happiness': 5}),
      _c('Dizer adeus', 'Foi triste ver {npc} partir.', {'happiness': -6, 'removeTarget': true}),
    ], req: ['friends'], target: 'friend', weight: 0.6),
    _e('soc_celebrity_meet', 'social', 14, 80, 'Encontro Inesperado', 'No aeroporto, você reconhece a famosa cantora fictícia Luna Vértice tomando um café.', [
      _c('Pedir uma selfie', 'Ela foi super simpática! A foto bombou nas suas redes.', {'followers': 2500, 'happiness': 12, 'fame': 2}),
      _c('Puxar conversa de verdade', 'Vocês conversaram por meia hora. Ela te seguiu nas redes!', {'followers': 8000, 'fame': 5, 'charisma': 4}, 0.4, 'Os seguranças te afastaram antes de você dizer oi.', {'happiness': -3}),
      _c('Deixar ela em paz', 'Você respeitou a privacidade dela.', {'karma': 4}),
    ], rarity: 'uncommon'),
    _e('soc_volunteer', 'social', 12, 90, 'Trabalho Voluntário', 'Uma ONG do bairro precisa de voluntários no fim de semana.', [
      _c('Participar', 'Ajudar os outros encheu seu coração.', {'karma': 12, 'happiness': 8, 'reputation': 5}),
      _c('Doar R\$ 500', 'Sua doação comprou cestas básicas para 10 famílias.', {'money': -500, 'karma': 10, 'reputation': 3}),
      _c('Não ter tempo', 'Fica para a próxima.', {}),
    ]),
    _e('soc_enemy_sabotage', 'social', 14, 70, 'Sabotagem', '{npc} está tentando te prejudicar falando mal de você para todos.', [
      _c('Propor uma trégua', 'Vocês conversaram e descobriram que tudo foi um mal-entendido.', {'rel': 40, 'karma': 6}, 0.45, '{npc} riu da sua proposta.', {'stress': 6}),
      _c('Revidar', 'Você expôs as mentiras de {npc}. Missão cumprida, mas a guerra continua.', {'reputation': 4, 'rel': -15, 'karma': -4}),
    ], target: 'rival'),
    // ================================================================ CARREIRA
    _e('car_promotion_offer', 'carreira', 18, 70, 'Oportunidade de Crescimento', 'Seu chefe ofereceu liderar um projeto difícil e de alta visibilidade.', [
      _c('Aceitar o desafio', 'O projeto foi um sucesso! Você foi promovido(a).', {'promote': true, 'stress': 10, 'performance': 15}, 0.6, 'O projeto atrasou e sua imagem saiu arranhada.', {'performance': -15, 'stress': 15}),
      _c('Recusar com educação', 'Você manteve o equilíbrio entre vida e trabalho.', {'stress': -5}),
    ], req: ['job']),
    _e('car_layoff', 'carreira', 18, 70, 'Reestruturação', 'A empresa anunciou cortes. Há boatos de que seu cargo está na lista.', [
      _c('Trabalhar dobrado para provar valor', 'Seu esforço foi notado e você foi poupado(a).', {'performance': 15, 'stress': 12}, 0.65, 'Não adiantou. Você foi demitido(a) com a rescisão paga.', {'loseJob': true, 'money': 8000, 'happiness': -12}),
      _c('Negociar uma demissão voluntária', 'Você saiu com um bom pacote de indenização.', {'loseJob': true, 'money': 25000, 'happiness': -4}),
      _c('Procurar outro emprego antes', 'Você mandou currículos discretamente. Ficou mais ansioso(a).', {'stress': 8}),
    ], req: ['job'], weight: 0.7),
    _e('car_boss_conflict', 'carreira', 18, 70, 'Chefe Exigente', '{npc} te passou uma tarefa absurda para entregar em 24 horas.', [
      _c('Virar a noite e entregar', '{npc} ficou impressionado(a)!', {'performance': 12, 'rel': 10, 'health': -4, 'stress': 10}),
      _c('Negociar o prazo', '{npc} aceitou, mas não ficou muito feliz.', {'performance': -2, 'rel': -3}),
      _c('Reclamar no RH', 'O RH interveio. {npc} passou a te tratar com frieza.', {'rel': -15, 'karma': 2}),
    ], req: ['job'], target: 'boss'),
    _e('car_headhunter', 'carreira', 22, 65, 'Proposta de Headhunter', 'Uma concorrente quer te contratar com salário 25% maior.', [
      _c('Aceitar a proposta', 'Novo crachá, novo salário!', {'raisePct': 0.25, 'happiness': 10, 'stress': 5}),
      _c('Usar para negociar aumento', 'Sua empresa cobriu a oferta para não te perder!', {'raisePct': 0.15, 'performance': 5}, 0.6, 'Seu chefe não gostou da chantagem e ficou desconfiado.', {'performance': -12}),
      _c('Recusar por lealdade', 'Seu chefe soube e ficou muito grato.', {'performance': 8, 'karma': 4}),
    ], req: ['job'], weight: 0.6),
    _e('car_coworker_credit', 'carreira', 18, 70, 'Ideia Roubada', '{npc} apresentou a SUA ideia na reunião como se fosse dele(a).', [
      _c('Corrigir na frente de todos', 'Você provou a autoria com e-mails. Respeito conquistado.', {'performance': 10, 'rel': -20, 'reputation': 5}),
      _c('Conversar em particular', '{npc} pediu desculpas e prometeu te dar crédito.', {'rel': 5, 'karma': 3}),
      _c('Deixar pra lá', 'Ninguém soube que a ideia era sua.', {'performance': -5, 'happiness': -6}),
    ], req: ['job'], target: 'coworker'),
    _e('car_office_party', 'carreira', 18, 70, 'Festa da Firma', 'É a confraternização de fim de ano da empresa, com karaokê e open bar.', [
      _c('Soltar a voz no karaokê', 'Você foi a estrela da noite!', {'charisma': 4, 'happiness': 8, 'addNpc': 'coworker'}, 0.7, 'Você exagerou na bebida e o vídeo foi parar no grupo da empresa.', {'reputation': -10, 'performance': -8}),
      _c('Fazer networking com a diretoria', 'Você causou boa impressão nos chefões.', {'performance': 8, 'charisma': 2}),
      _c('Ir embora cedo', 'Você descansou para o fim de semana.', {'energy': 8}),
    ], req: ['job']),
    _e('car_burnout', 'carreira', 22, 70, 'Esgotamento', 'Você anda exausto(a), dormindo mal e irritado(a) com tudo.', [
      _c('Tirar licença médica', 'Você descansou e voltou renovado(a).', {'stress': -25, 'health': 6, 'performance': -5}),
      _c('Seguir no ritmo', 'Seu corpo cobrou o preço.', {'condition': 'burnout', 'health': -10, 'stress': 10}),
      _c('Começar terapia', 'A terapia te ajudou a impor limites.', {'money': -1200, 'stress': -18, 'happiness': 6}),
    ], req: ['job']),
    // ================================================================ FINANCEIRO
    _e('fin_found_wallet', 'financeiro', 8, 90, 'Carteira Perdida', 'Você encontrou uma carteira com R\$ 800 e documentos na calçada.', [
      _c('Devolver ao dono', 'O dono ficou tão grato que te deu R\$ 200 de recompensa!', {'money': 200, 'karma': 12, 'reputation': 4}),
      _c('Ficar com o dinheiro', 'Dinheiro fácil... mas a consciência pesou.', {'money': 800, 'karma': -15}),
    ]),
    _e('fin_investment_tip', 'financeiro', 20, 80, 'Dica Quente', 'Um conhecido jura que uma ação vai triplicar e sugere investir R\$ 5.000.', [
      _c('Investir R\$ 5.000', 'A ação disparou! Você lucrou R\$ 12.000.', {'money': 12000}, 0.4, 'A empresa faliu. Você perdeu tudo.', {'money': -5000, 'stress': 8}),
      _c('Pesquisar antes', 'Você descobriu que era golpe. Livrou-se de uma furada.', {'smarts': 4}),
    ], req: ['adult']),
    _e('fin_car_broke', 'financeiro', 18, 85, 'Imprevisto Caro', 'Seu carro quebrou no meio da estrada.', [
      _c('Guincho e oficina (R\$ 2.500)', 'O carro voltou novinho.', {'money': -2500, 'stress': 5}),
      _c('Tentar consertar sozinho', 'Você salvou o dia com fita e criatividade!', {'smarts': 3, 'happiness': 4}, 0.4, 'Piorou o problema. A conta veio maior: R\$ 4.000.', {'money': -4000, 'stress': 8}),
    ], req: ['hasCar']),
    _e('fin_tax_refund', 'financeiro', 18, 90, 'Restituição do Imposto', 'A Receita liberou sua restituição do imposto de renda.', [
      _c('Guardar na poupança', 'Dinheiro guardado é dinheiro rendendo.', {'money': 2200, 'smarts': 1}),
      _c('Gastar numa viagem', 'Um fim de semana incrível na serra!', {'happiness': 12, 'stress': -10}),
    ], req: ['job']),
    _e('fin_scam_call', 'financeiro', 16, 90, 'Ligação Suspeita', 'Alguém liga dizendo ser do banco e pede seus dados para "bloquear uma fraude".', [
      _c('Passar os dados', 'Era golpe! Esvaziaram parte da sua conta.', {'moneyPct': -0.25, 'stress': 15, 'happiness': -10}),
      _c('Desligar e ligar para o banco', 'O banco confirmou: era golpe. Você se protegeu!', {'smarts': 3}),
    ]),
    _e('fin_lucky_raffle', 'financeiro', 10, 90, 'Rifa da Igreja', 'Você comprou um número da rifa da quermesse por R\$ 10.', [
      _c('Torcer!', 'Você ganhou uma TV novinha!', {'money': -10, 'item': 'el_tv', 'happiness': 12}, 0.15, 'Não foi dessa vez, mas ajudou uma boa causa.', {'money': -10, 'karma': 3}),
    ]),
    _e('fin_debt_collector', 'financeiro', 18, 90, 'Cobrança Pesada', 'Um credor está ligando todos os dias cobrando suas dívidas.', [
      _c('Negociar um acordo', 'Você conseguiu 40% de desconto!', {'debt': -3000, 'stress': -6}),
      _c('Ignorar as ligações', 'Seu nome foi negativado.', {'stress': 12, 'reputation': -5}),
    ], req: ['indebted']),
    _e('fin_side_hustle', 'financeiro', 16, 70, 'Renda Extra', 'Um amigo te convida para vender doces caseiros nos fins de semana.', [
      _c('Topar o negócio', 'Os brigadeiros fizeram sucesso! R\$ 3.500 de lucro.', {'money': 3500, 'energy': -8, 'charisma': 3}),
      _c('Descansar nos fins de semana', 'Você priorizou seu descanso.', {'stress': -6}),
    ]),
    // ================================================================ SAÚDE
    _e('hea_flu', 'saúde', 3, 90, 'Gripe Forte', 'Você acordou com febre alta e o corpo todo doendo.', [
      _c('Ir ao médico', 'Remédio certo e repouso: você melhorou em 5 dias.', {'money': -150, 'health': 2}),
      _c('Tomar chá e esperar', 'A gripe durou semanas.', {'condition': 'flu', 'health': -8}),
    ]),
    _e('hea_accident', 'saúde', 6, 80, 'Acidente', 'Você escorregou na escada e caiu feio.', [
      _c('Ir ao pronto-socorro', 'Fratura no braço! Gesso por 6 semanas.', {'condition': 'fracture', 'health': -10, 'money': -300}),
      _c('Fazer compressa em casa', 'Era só uma torção. Ufa!', {'health': -3}, 0.6, 'Era uma fratura! Demorou mais para curar.', {'condition': 'fracture', 'health': -15}),
    ]),
    _e('hea_checkup', 'saúde', 30, 90, 'Exame de Rotina', 'O médico recomendou um check-up completo.', [
      _c('Fazer os exames (R\$ 600)', 'Tudo em ordem! Você recebeu dicas para viver mais.', {'money': -600, 'health': 8}),
      _c('Deixar para depois', 'Você adiou mais uma vez...', {'health': -3}),
    ]),
    _e('hea_diet', 'saúde', 14, 80, 'Hora de Mudar', 'Você se olhou no espelho e decidiu cuidar melhor da saúde.', [
      _c('Dieta e academia', 'Em três meses você estava irreconhecível!', {'health': 8, 'looks': 6, 'fitness': 10, 'money': -900}),
      _c('Começar a correr no parque', 'Correr virou seu momento favorito do dia.', {'health': 6, 'fitness': 8, 'stress': -8}),
      _c('Começo na segunda', 'A segunda nunca chegou.', {'happiness': -2}),
    ]),
    _e('hea_food_poisoning', 'saúde', 8, 90, 'Comida de Rua', 'Aquele pastel da feira estava com uma cara estranha...', [
      _c('Comer mesmo assim', 'Estava delicioso! Seu estômago é de aço.', {'happiness': 5}, 0.5, 'Intoxicação alimentar! Dois dias de cama.', {'condition': 'food_poisoning', 'health': -8}),
      _c('Melhor não arriscar', 'Você comeu uma salada em casa.', {'health': 1}),
    ]),
    _e('hea_recovery', 'saúde', 10, 90, 'Recuperação Milagrosa', 'Seu corpo reagiu incrivelmente bem ao tratamento.', [
      _c('Agradecer e seguir em frente', 'Você está se sentindo novo(a) em folha!', {'cure': true, 'health': 15, 'happiness': 10}),
    ], req: ['sick'], weight: 0.8),
    _e('hea_back_pain', 'saúde', 35, 90, 'Dor nas Costas', 'Uma dor lombar insuportável te impede de levantar.', [
      _c('Fisioterapia (R\$ 2.000)', 'Sessões de RPG resolveram o problema.', {'money': -2000, 'health': 5}),
      _c('Ignorar a dor', 'Virou uma hérnia de disco.', {'condition': 'back_pain', 'health': -8}),
    ]),
    // ================================================================ AMOR
    _e('love_blind_date', 'amor', 18, 70, 'Encontro às Cegas', 'Um amigo arranjou um encontro às cegas para você.', [
      _c('Ir ao encontro', 'Química instantânea! Vocês começaram a namorar.', {'addNpc': 'partner', 'happiness': 15}, 0.45, 'A pessoa passou a noite falando do ex. Constrangedor.', {'happiness': -4}),
      _c('Inventar uma desculpa', 'Você ficou em casa com pizza.', {}),
    ], req: ['single', 'adult']),
    _e('love_anniversary', 'amor', 16, 90, 'Aniversário de Namoro', 'É aniversário de relacionamento com {npc}.', [
      _c('Jantar romântico (R\$ 400)', 'Noite perfeita! {npc} ficou encantado(a).', {'money': -400, 'rel': 15, 'happiness': 10}),
      _c('Carta escrita à mão', 'Simples e emocionante. {npc} chorou de alegria.', {'rel': 12, 'happiness': 6}),
      _c('Esquecer a data', '{npc} ficou muito magoado(a).', {'rel': -20, 'happiness': -6}),
    ], req: ['partner'], target: 'partner'),
    _e('love_jealousy', 'amor', 16, 80, 'Crise de Ciúmes', '{npc} viu uma mensagem no seu celular e ficou desconfiado(a).', [
      _c('Explicar com calma', '{npc} entendeu que era bobagem.', {'rel': 4}),
      _c('Ficar ofendido(a)', 'A briga durou dias.', {'rel': -15, 'stress': 8}),
    ], req: ['partner'], target: 'partner'),
    _e('love_temptation', 'amor', 18, 70, 'Tentação', 'Alguém muito atraente está flertando descaradamente com você, mesmo sabendo que você namora {npc}.', [
      _c('Cortar o flerte', 'Você foi fiel. {npc} nem ficou sabendo, mas sua consciência está em paz.', {'karma': 8}),
      _c('Ceder à tentação', 'Foi emocionante... até {npc} descobrir. O relacionamento acabou.', {'breakUp': true, 'karma': -15, 'happiness': -12}, 0.35, 'Ninguém descobriu, mas a culpa te consome.', {'karma': -12, 'stress': 12}),
    ], req: ['partner'], target: 'partner', weight: 0.6),
    _e('love_proposal_hint', 'amor', 20, 70, 'Indiretas', '{npc} anda falando muito de casamento e mostrando fotos de anéis.', [
      _c('Fazer o pedido!', '{npc} disse SIM! Vocês se casaram numa cerimônia linda.', {'marryTarget': true, 'money': -12000, 'happiness': 25}, 0.85, '{npc} se assustou e pediu mais tempo.', {'rel': -6}),
      _c('Desconversar', '{npc} ficou decepcionado(a).', {'rel': -12}),
    ], req: ['dating'], target: 'partner'),
    _e('love_baby_news', 'amor', 20, 45, 'Grande Notícia', '{npc} chegou com um teste de gravidez positivo!', [
      _c('Comemorar!', 'Meses depois nasceu um bebê lindo e saudável!', {'baby': true, 'happiness': 20, 'rel': 15}),
      _c('Entrar em pânico', 'O susto passou e o amor falou mais alto. O bebê nasceu!', {'baby': true, 'happiness': 8, 'stress': 15}),
    ], req: ['married'], target: 'spouse', weight: 0.6),
    _e('love_ex_returns', 'amor', 18, 70, 'O Ex Voltou', '{npc} mandou mensagem dizendo que se arrependeu e quer voltar.', [
      _c('Dar outra chance', 'Vocês reataram e desta vez está dando certo!', {'partnerFromTarget': true, 'happiness': 12}),
      _c('Bloquear o contato', 'Página virada.', {'happiness': 2, 'removeTarget': true}),
    ], req: ['single'], target: 'ex'),
    _e('love_crush_move', 'amor', 14, 60, 'Momento Certo', 'Você e {npc} estão cada vez mais próximos. O clima está no ar...', [
      _c('Chamar para sair', '{npc} aceitou! Agora vocês estão namorando.', {'partnerFromTarget': true, 'happiness': 18}, 0.65, '{npc} disse que prefere a amizade.', {'happiness': -8, 'rel': -5}),
      _c('Esperar mais um pouco', 'A paquera continua...', {'rel': 3}),
    ], req: ['single'], target: 'crush'),
    _e('love_divorce_threat', 'amor', 25, 90, 'Casamento em Crise', 'Você e {npc} brigam todos os dias. A palavra "divórcio" apareceu.', [
      _c('Terapia de casal (R\$ 3.000)', 'A terapia salvou o casamento!', {'money': -3000, 'rel': 25}, 0.7, 'Não houve acordo. Vocês se divorciaram.', {'breakUp': true, 'moneyPct': -0.3, 'happiness': -15}),
      _c('Pedir o divórcio', 'Vocês se separaram e dividiram os bens.', {'breakUp': true, 'moneyPct': -0.35, 'happiness': -10, 'stress': -5}),
      _c('Uma viagem a dois', 'Longe da rotina, vocês se reencontraram.', {'money': -5000, 'rel': 20, 'happiness': 8}),
    ], req: ['married'], target: 'spouse', weight: 0.5),
    // ================================================================ FAMA
    _e('fame_viral', 'fama', 13, 80, 'Vídeo Viral', 'Um vídeo seu dançando no metrô explodiu na internet!', [
      _c('Abraçar a fama', 'Você virou meme nacional e ganhou milhares de seguidores!', {'followers': 25000, 'fame': 8, 'happiness': 10}),
      _c('Pedir para tirarem do ar', 'O vídeo sumiu, mas alguns ainda te reconhecem.', {'followers': 2000, 'fame': 2}),
    ], weight: 0.6),
    _e('fame_sponsor', 'fama', 14, 80, 'Proposta de Patrocínio', 'Uma marca de bebidas energéticas quer te patrocinar.', [
      _c('Assinar contrato de 3 anos', 'Você recebe R\$ 60.000 por ano para divulgar a marca!', {'sponsorship': ['VoltaX Energy', 60000, 3], 'fame': 4}),
      _c('Recusar — não combina com você', 'Seus fãs admiraram sua autenticidade.', {'reputation': 6, 'followers': 3000}),
    ], req: ['famous']),
    _e('fame_scandal', 'fama', 16, 90, 'Polêmica!', 'Um tweet antigo seu ressurgiu e a internet está furiosa.', [
      _c('Pedir desculpas publicamente', 'O pedido sincero acalmou os ânimos.', {'reputation': -3, 'followers': -2000}),
      _c('Dobrar a aposta', 'Metade te cancelou, a outra metade te idolatra.', {'reputation': -12, 'followers': 10000, 'fame': 5}),
      _c('Sumir das redes por um tempo', 'Quando voltou, todos já tinham esquecido.', {'followers': -5000, 'stress': -5}),
    ], req: ['famous']),
    _e('fame_interview', 'fama', 16, 90, 'Entrevista na TV', 'Um programa de auditório convidou você para uma entrevista ao vivo.', [
      _c('Ser divertido(a) e espontâneo(a)', 'Você roubou a cena! Audiência recorde.', {'fame': 8, 'followers': 40000, 'charisma': 4}, 0.65, 'Você travou ao vivo e virou meme pelo motivo errado.', {'reputation': -6, 'followers': 5000}),
      _c('Falar de um projeto social', 'Sua causa ganhou visibilidade nacional.', {'reputation': 10, 'karma': 8, 'fame': 4}),
    ], req: ['famous']),
    _e('fame_paparazzi', 'fama', 16, 90, 'Paparazzi', 'Fotógrafos estão acampados na frente da sua casa.', [
      _c('Posar e sorrir', 'As fotos saíram ótimas nas revistas.', {'fame': 3, 'looks': 1}),
      _c('Chamar a segurança', 'Você ganhou paz, mas a imprensa te chamou de antipático(a).', {'reputation': -4, 'stress': -5}),
    ], req: ['famous'], weight: 0.6),
    // ================================================================ CRIME / MORAL
    _e('crime_shoplift_dare', 'crime', 12, 18, 'Desafio dos Amigos', 'Seus amigos te desafiam a pegar um chocolate sem pagar.', [
      _c('Aceitar o desafio', 'Você conseguiu e os amigos te acharam o máximo.', {'karma': -8, 'reputation': 3}, 0.6, 'O segurança te pegou! Seus pais foram chamados.', {'karma': -10, 'reputation': -8, 'relAll': -8}),
      _c('Recusar', 'Você foi zoado(a), mas manteve sua integridade.', {'karma': 6}),
    ]),
    _e('crime_witness', 'crime', 14, 90, 'Testemunha', 'Você presenciou um assalto e a polícia pede seu depoimento.', [
      _c('Testemunhar', 'Sua coragem ajudou a prender o criminoso.', {'karma': 10, 'reputation': 6, 'stress': 6}),
      _c('Fingir que não viu', 'Você evitou problemas, mas a culpa ficou.', {'karma': -5}),
    ]),
    // ================================================================ RAROS
    _e('rare_lottery', 'raro', 18, 95, 'Bilhete Premiado?', 'Você conferiu um bilhete de loteria esquecido na gaveta. Os números parecem familiares...', [
      _c('Conferir com calma', 'VOCÊ GANHOU NA LOTERIA! R\$ 2.500.000 caíram na sua conta!', {'money': 2500000, 'happiness': 40, 'headline': 'Sortudo(a) da cidade fatura prêmio milionário!'}, 0.35, 'Faltou um número. Quase!', {'happiness': -5}),
    ], rarity: 'legendary', weight: 0.25),
    _e('rare_millionaire_inheritance', 'raro', 18, 90, 'Herança Milionária', 'Um advogado te procura: um parente distante que você nunca conheceu deixou tudo para você.', [
      _c('Aceitar a herança', 'Você herdou uma fortuna!', {'inheritance': [800000, 3000000], 'happiness': 25, 'headline': 'Herdeiro(a) misterioso(a) recebe fortuna de parente distante'}),
      _c('Doar metade para caridade', 'Você ficou com metade e transformou vidas com o resto.', {'inheritance': [400000, 1500000], 'karma': 25, 'reputation': 15}),
    ], rarity: 'legendary', weight: 0.25),
    _e('rare_talent', 'raro', 6, 60, 'Talento Escondido', 'Brincando com um instrumento de um amigo, você percebeu que tem um dom natural.', [
      _c('Dedicar-se de corpo e alma', 'Em meses você tocava como profissional!', {'charisma': 10, 'happiness': 12, 'course': 'singing', 'fame': 3}),
      _c('Manter como hobby', 'Virou seu passatempo favorito.', {'happiness': 8, 'stress': -8}),
    ], rarity: 'rare', weight: 0.5),
    _e('rare_scout', 'raro', 12, 24, 'Olheiro', 'Um olheiro de um grande clube viu você jogando bola no parque.', [
      _c('Fazer o teste', 'Você foi aprovado(a) na peneira! Seu físico melhorou muito.', {'fitness': 15, 'fame': 5, 'happiness': 15, 'followers': 3000}, 0.5, 'Não passou desta vez, mas a experiência valeu.', {'fitness': 5, 'happiness': -4}),
      _c('Preferir os estudos', 'Você seguiu com o plano original.', {'smarts': 3}),
    ], rarity: 'rare', weight: 0.5),
    _e('rare_model', 'raro', 15, 35, 'Descoberta no Shopping', 'Uma agência de modelos te abordou no shopping.', [
      _c('Fazer um ensaio', 'Você estampou a capa de uma revista!', {'looks': 6, 'fame': 10, 'money': 8000, 'followers': 20000}, 0.6, 'Era uma agência falsa que cobrava taxas. Você perdeu R\$ 1.500.', {'money': -1500, 'smarts': 2}),
      _c('Recusar', 'Você não curte holofotes.', {}),
    ], rarity: 'rare', weight: 0.5),
    _e('rare_startup_offer', 'raro', 20, 60, 'Investidor Anjo', 'Um investidor viu um projeto seu e quer comprar sua ideia.', [
      _c('Vender a ideia (R\$ 400.000)', 'Negócio fechado! Você ficou rico(a) da noite para o dia.', {'money': 400000, 'happiness': 20, 'reputation': 8}),
      _c('Recusar e construir sozinho(a)', 'Você acredita no seu potencial... e ganhou experiência.', {'smarts': 5, 'charisma': 3}),
    ], rarity: 'rare', weight: 0.35),
    _e('rare_meteor', 'raro', 8, 95, 'Pedra do Céu', 'Um pequeno meteorito caiu no seu quintal!', [
      _c('Vender para um museu', 'O museu pagou R\$ 120.000 pela peça rara!', {'money': 120000, 'headline': 'Meteorito cai em quintal e vira peça de museu', 'fame': 4}),
      _c('Guardar como lembrança', 'Ele brilha na sua estante até hoje.', {'happiness': 10, 'smarts': 3}),
    ], rarity: 'legendary', weight: 0.15),
    _e('rare_hero', 'raro', 14, 80, 'Ato Heroico', 'Uma criança está se afogando no lago do parque!', [
      _c('Pular na água', 'Você salvou a criança e virou herói(na) da cidade!', {'karma': 25, 'reputation': 20, 'fame': 10, 'followers': 30000, 'headline': 'Herói(na) anônimo(a) salva criança em lago'}, 0.8, 'Você salvou a criança, mas se machucou bastante.', {'karma': 25, 'health': -15, 'reputation': 15}),
      _c('Gritar por socorro', 'Um salva-vidas chegou a tempo.', {'karma': 5}),
    ], rarity: 'rare', weight: 0.3),
  ];
}
