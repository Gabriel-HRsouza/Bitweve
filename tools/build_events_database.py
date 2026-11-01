import json
import os

events = [
    # 1. INFÂNCIA (0-6)
    {
        "id": "child_wall_art",
        "category": "infância",
        "minAge": 2, "maxAge": 5,
        "title": "Obra de Arte na Parede",
        "description": "Você encontrou canetinhas coloridas sem tampa e uma parede branca recém-pintada na sala.",
        "choices": [
            {"label": "Fazer um mural abstrato gigante", "healthDelta": 0, "happinessDelta": 15, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": -5, "stressDelta": 0, "reputationDelta": -5, "moneyDelta": 0, "resultText": "Seus pais ficaram desesperados, mas tiraram foto antes de limpar."},
            {"label": "Desenhar no papel", "healthDelta": 0, "happinessDelta": 5, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 5, "stressDelta": -5, "reputationDelta": 10, "moneyDelta": 0, "resultText": "Você foi elogiado por ser uma criança comportada e educada."},
            {"label": "Pintar a própria barriga", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": -5, "looksDelta": 5, "karmaDelta": 0, "stressDelta": 5, "reputationDelta": 0, "moneyDelta": 0, "resultText": "O banho depois foi uma batalha épica com sabonete."}
        ]
    },
    {
        "id": "child_first_friend",
        "category": "infância",
        "minAge": 3, "maxAge": 6,
        "title": "Amigo no Parquinho",
        "description": "No parquinho do bairro, outra criança oferece metade de um biscoito recheado pra você.",
        "choices": [
            {"label": "Aceitar e brincar no escorregador juntos", "healthDelta": 5, "happinessDelta": 20, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": 10, "stressDelta": -10, "reputationDelta": 10, "moneyDelta": 0, "resultText": "Vocês se divertiram a tarde toda e viraram grandes companheiros de recreio!"},
            {"label": "Recusar com desconfiança", "healthDelta": 0, "happinessDelta": -5, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": -5, "stressDelta": 5, "reputationDelta": -5, "moneyDelta": 0, "resultText": "A criança ficou triste e foi brincar com o balanço sozinha."}
        ]
    },

    # 2. ESCOLA & ESTUDOS (6-18)
    {
        "id": "school_science_fair",
        "category": "escola",
        "minAge": 8, "maxAge": 14,
        "title": "A Feira de Ciências da Escola",
        "description": "Chegou a feira anual de ciências e seu grupo precisa decidir o projeto final.",
        "choices": [
            {"label": "Construir um vulcão com bicarbonato e iluminação LED", "healthDelta": 0, "happinessDelta": 20, "smartsDelta": 20, "looksDelta": 5, "karmaDelta": 5, "stressDelta": -5, "reputationDelta": 25, "moneyDelta": -30, "resultText": "Primeiro lugar na feira! A erupção foi fantástica e impressionou os jurados."},
            {"label": "Copiar um cartaz pronto da internet na véspera", "healthDelta": 0, "happinessDelta": -5, "smartsDelta": -10, "looksDelta": 0, "karmaDelta": -10, "stressDelta": 15, "reputationDelta": -15, "moneyDelta": 0, "resultText": "O professor percebeu a cópia e deu apenas nota mínima."},
            {"label": "Faltar no dia para jogar bola", "healthDelta": 5, "happinessDelta": 10, "smartsDelta": -15, "looksDelta": 0, "karmaDelta": -15, "stressDelta": 15, "reputationDelta": -20, "moneyDelta": 0, "resultText": "Seu grupo ficou na mão e seus pais foram chamados na diretoria."}
        ]
    },
    {
        "id": "school_exam_cheating",
        "category": "estudos",
        "minAge": 11, "maxAge": 17,
        "title": "A Colinha da Prova",
        "description": "Seu colega da frente deixa cair no chão um papel com todo o gabarito da prova de matemática.",
        "choices": [
            {"label": "Ignorar a colinha e fazer pelo próprio esforço", "healthDelta": 0, "happinessDelta": 15, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 15, "stressDelta": -5, "reputationDelta": 15, "moneyDelta": 0, "resultText": "Você tirou 8,5 com mérito próprio e se sentiu muito orgulhoso."},
            {"label": "Copiar as respostas rapidinho", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": -10, "looksDelta": 0, "karmaDelta": -15, "stressDelta": 15, "reputationDelta": -5, "moneyDelta": 0, "resultText": "Você tirou nota 9,5, mas não aprendeu nada do conteúdo."},
            {"label": "Chamar o professor e entregar o papel", "healthDelta": 0, "happinessDelta": -10, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": -5, "stressDelta": 20, "reputationDelta": -25, "moneyDelta": 0, "resultText": "O professor agradeceu, mas a turma inteira te chamou de dedo-duro."}
        ]
    },

    # 3. ADOLESCÊNCIA (12-18)
    {
        "id": "teen_first_crush",
        "category": "adolescência",
        "minAge": 12, "maxAge": 17,
        "title": "Borboletas no Estômago",
        "description": "A pessoa por quem você tem uma quedinha sentou do seu lado no intervalo e puxou assunto sobre músicas.",
        "choices": [
            {"label": "Puxar assunto com entusiasmo e bom humor", "healthDelta": 0, "happinessDelta": 25, "smartsDelta": 5, "looksDelta": 10, "karmaDelta": 5, "stressDelta": -10, "reputationDelta": 15, "moneyDelta": 0, "resultText": "O papo fluiu tão bem que vocês trocaram redes sociais e não pararam de conversar!"},
            {"label": "Ficar tímido e responder monossilábico", "healthDelta": 0, "happinessDelta": -10, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 15, "reputationDelta": -5, "moneyDelta": 0, "resultText": "Ficou um silêncio constrangedor e a pessoa foi embora logo em seguida."}
        ]
    },

    # 4. TRABALHO & PROMOÇÕES
    {
        "id": "career_internship_offer",
        "category": "trabalho",
        "minAge": 18, "maxAge": 28,
        "title": "Vaga de Estágio Promissora",
        "description": "Uma empresa inovadora ofereceu uma vaga de estágio com bolsa razoável e muito aprendizado.",
        "choices": [
            {"label": "Aceitar e dar o sangue no estágio", "healthDelta": -5, "happinessDelta": 15, "smartsDelta": 20, "looksDelta": 0, "karmaDelta": 5, "stressDelta": 15, "reputationDelta": 20, "moneyDelta": 1500, "resultText": "O ritmo é puxado, mas suas habilidades explodiram e a chefia te elogia bastante."},
            {"label": "Negociar horário para não atrapalhar os estudos", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 5, "stressDelta": 5, "reputationDelta": 15, "moneyDelta": 1200, "resultText": "A diretoria respeitou sua postura profissional madura e ajustou o contrato."}
        ]
    },
    {
        "id": "career_promotion_challenge",
        "category": "promoções",
        "minAge": 22, "maxAge": 55,
        "title": "A Disputa pela Gerência",
        "description": "Uma vaga executiva abriu no seu setor. Seu principal concorrente espalha boatos discretos sobre você.",
        "choices": [
            {"label": "Focar em entregar resultados extraordinários e bater metas", "healthDelta": -5, "happinessDelta": 30, "smartsDelta": 20, "looksDelta": 5, "karmaDelta": 15, "stressDelta": 15, "reputationDelta": 35, "moneyDelta": 5000, "resultText": "A diretoria reconheceu sua competência inquestionável e você foi promovido a Gerente!"},
            {"label": "Pagar na mesma moeda e espalhar fofocas sobre ele", "healthDelta": -10, "happinessDelta": -15, "smartsDelta": -5, "looksDelta": 0, "karmaDelta": -25, "stressDelta": 30, "reputationDelta": -25, "moneyDelta": 0, "resultText": "O ambiente virou um campo de guerra e a diretoria congelou a vaga para os dois."},
            {"label": "Ter uma conversa franca com o colega e alinhar jogo limpo", "healthDelta": 5, "happinessDelta": 15, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 20, "stressDelta": -15, "reputationDelta": 20, "moneyDelta": 0, "resultText": "Ele ficou sem graça, pediu desculpas e a competição voltou a ser saudável."}
        ]
    },

    # 5. RELACIONAMENTOS & FAMÍLIA
    {
        "id": "rel_romantic_anniversary",
        "category": "relacionamentos",
        "minAge": 18, "maxAge": 70,
        "title": "Aniversário Especial de Casal",
        "description": "Hoje é data especial no relacionamento. Seu par preparou um olhar de expectativa.",
        "choices": [
            {"label": "Reservar um jantar surpresa à luz de velas", "healthDelta": 5, "happinessDelta": 25, "smartsDelta": 0, "looksDelta": 10, "karmaDelta": 10, "stressDelta": -15, "reputationDelta": 10, "moneyDelta": -350, "resultText": "A noite foi inesquecível, cheia de carinho, cumplicidade e romance."},
            {"label": "Cozinhar um prato refinado em casa com carinho", "healthDelta": 5, "happinessDelta": 20, "smartsDelta": 10, "looksDelta": 5, "karmaDelta": 10, "stressDelta": -10, "reputationDelta": 5, "moneyDelta": -100, "resultText": "O prato ficou delicioso e o clima caseiro foi aconchegante demais."}
        ]
    },
    {
        "id": "family_bbq_quarrel",
        "category": "família",
        "minAge": 18, "maxAge": 75,
        "title": "O Churrasco de Domingo da Família",
        "description": "Seus tios começaram uma discussão acalorada sobre política no meio do almoço de domingo.",
        "choices": [
            {"label": "Fazer uma piada espirituosa e mudar o assunto pro futebol", "healthDelta": 5, "happinessDelta": 20, "smartsDelta": 15, "looksDelta": 5, "karmaDelta": 20, "stressDelta": -20, "reputationDelta": 25, "moneyDelta": 0, "resultText": "Todo mundo riu, a tensão sumiu e o churrasco foi salvo com alegria!"},
            {"label": "Entrar na discussão defendendo seu ponto de vista", "healthDelta": -5, "happinessDelta": -20, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": -10, "stressDelta": 25, "reputationDelta": -10, "moneyDelta": 0, "resultText": "Houve gritaria, portas batendo e o almoço acabou mais cedo num climão horrível."},
            {"label": "Pegar mais um pedaço de picanha e sair de fininho", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -5, "reputationDelta": 0, "moneyDelta": 0, "resultText": "A carne estava uma delícia e você preservou sua paz de espírito."}
        ]
    },

    # 6. AMIZADES
    {
        "id": "friend_borrow_money",
        "category": "amizades",
        "minAge": 18, "maxAge": 65,
        "title": "O Empréstimo do Amigo de Infância",
        "description": "Seu amigo mais antigo está passando por um aperto financeiro e pede R$ 800 emprestados.",
        "choices": [
            {"label": "Emprestar de coração sem cobrar juros", "healthDelta": 0, "happinessDelta": 15, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 25, "stressDelta": 0, "reputationDelta": 20, "moneyDelta": -800, "resultText": "Ele te agradeceu muito emocionado e meses depois devolveu cada centavo com um presente!"},
            {"label": "Explicar educadamente que seu orçamento está apertado", "healthDelta": 0, "happinessDelta": 0, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -5, "reputationDelta": 0, "moneyDelta": 0, "resultText": "Ele compreendeu a situação e a amizade continuou intacta e respeitosa."},
            {"label": "Parar de atender as ligações dele", "healthDelta": 0, "happinessDelta": -15, "smartsDelta": -5, "looksDelta": 0, "karmaDelta": -20, "stressDelta": 15, "reputationDelta": -20, "moneyDelta": 0, "resultText": "A amizade de anos foi rompida e o remorso ficou no seu coração."}
        ]
    },

    # 7. SAÚDE & MÉDICO
    {
        "id": "health_checkup_discovery",
        "category": "saúde",
        "minAge": 25, "maxAge": 80,
        "title": "Check-up de Rotina",
        "description": "O médico aponta que suas taxas de colesterol estão ligeiramente elevadas e sugere mudanças de hábitos.",
        "choices": [
            {"label": "Adotar dieta balanceada e caminhadas diárias", "healthDelta": 25, "happinessDelta": 15, "smartsDelta": 10, "looksDelta": 10, "karmaDelta": 10, "stressDelta": -20, "reputationDelta": 10, "moneyDelta": -150, "resultText": "Seus exames seguintes normalizaram e você ganhou uma energia impressionante!"},
            {"label": "Ignorar e pedir uma porção de batata frita com bacon", "healthDelta": -25, "happinessDelta": 10, "smartsDelta": -10, "looksDelta": -10, "karmaDelta": 0, "stressDelta": 15, "reputationDelta": -5, "moneyDelta": -50, "resultText": "A batata estava saborosa, mas logo o cansaço e falta de ar começaram a incomodar."}
        ]
    },
    {
        "id": "med_wisdom_teeth",
        "category": "médico",
        "minAge": 17, "maxAge": 32,
        "title": "O Temido Dente do Siso",
        "description": "Seu dente do siso inflamou de repente, causando dores latejantes na mandíbula.",
        "choices": [
            {"label": "Fazer a cirurgia de extração com um bom dentista", "healthDelta": 20, "happinessDelta": 15, "smartsDelta": 5, "looksDelta": 5, "karmaDelta": 5, "stressDelta": -15, "reputationDelta": 5, "moneyDelta": -600, "resultText": "Três dias comendo sorvete e a dor sumiu para sempre!"},
            {"label": "Tomar analgésicos e adiar a cirurgia", "healthDelta": -15, "happinessDelta": -15, "smartsDelta": -5, "looksDelta": -5, "karmaDelta": 0, "stressDelta": 20, "reputationDelta": 0, "moneyDelta": -40, "resultText": "A dor voltou pior no meio do expediente na semana seguinte."}
        ]
    },

    # 8. DINHEIRO, HERANÇA & COMPRAS
    {
        "id": "fin_crypto_scam_or_gem",
        "category": "dinheiro",
        "minAge": 18, "maxAge": 65,
        "title": "A Dica Quente do Colega",
        "description": "Um amigo do trabalho jura de pé junto que uma nova criptomoeda vai multiplicar por 50x até o mês que vem.",
        "choices": [
            {"label": "Colocar R$ 1.000 e arriscar a sorte", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": -5, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 20, "reputationDelta": 0, "moneyDelta": 2500, "resultText": "Por pura sorte o token subiu e você realizou um belo lucro antes do tombo!"},
            {"label": "Investir de forma prudente em renda fixa", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 5, "stressDelta": -10, "reputationDelta": 10, "moneyDelta": 120, "resultText": "Seu dinheiro continuou seguro e rendeu juros compostos com tranquilidade."}
        ]
    },
    {
        "id": "shop_dream_car",
        "category": "compras",
        "minAge": 20, "maxAge": 70,
        "title": "O Carro dos Sonhos na Concessionária",
        "description": "Você passa na concessionária e vê aquele carro esportivo preto brilhando na vitrine.",
        "choices": [
            {"label": "Comprar à vista e sair acelerando", "healthDelta": 5, "happinessDelta": 35, "smartsDelta": 0, "looksDelta": 20, "karmaDelta": 0, "stressDelta": -10, "reputationDelta": 30, "moneyDelta": -35000, "resultText": "O ronco do motor é pura música! Você virou o centro das atenções na rua."},
            {"label": "Guardar o dinheiro para investir em patrimônio real", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 20, "looksDelta": 0, "karmaDelta": 5, "stressDelta": -5, "reputationDelta": 10, "moneyDelta": 0, "resultText": "Decisão sensata que acelerou sua independência financeira a longo prazo."}
        ]
    },
    {
        "id": "heritage_great_aunt",
        "category": "herança",
        "minAge": 21, "maxAge": 75,
        "title": "A Carta do Tabelião",
        "description": "Você recebe uma notificação oficial de um cartório sobre a partilha de bens de uma tia-avó distante.",
        "choices": [
            {"label": "Comparecer com advogado e receber sua cota da partilha", "healthDelta": 0, "happinessDelta": 30, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 10, "stressDelta": -10, "reputationDelta": 15, "moneyDelta": 18000, "resultText": "Você herdou R$ 18.000 em títulos e um anel de ouro antigo de família!"},
            {"label": "Doar parte do valor para um asilo da cidade dela", "healthDelta": 5, "happinessDelta": 40, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 40, "stressDelta": -20, "reputationDelta": 35, "moneyDelta": 12000, "resultText": "O asilo fez uma homenagem linda e sua paz interior não tem preço."}
        ]
    },

    # 9. SORTE, AZAR & LOTERIA
    {
        "id": "luck_scratchcard",
        "category": "sorte",
        "minAge": 18, "maxAge": 85,
        "title": "A Raspadinha na Padaria",
        "description": "Ao comprar o pão francês da tarde, o atendente oferece o troco de R$ 10 em uma raspadinha premiada.",
        "choices": [
            {"label": "Aceitar a raspadinha e raspar com uma moeda", "healthDelta": 0, "happinessDelta": 25, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -5, "reputationDelta": 5, "moneyDelta": 1500, "resultText": "ACERTOU! Três símbolos idênticos! Você ganhou R$ 1.500 no caixa da padaria!"},
            {"label": "Pedir o troco em dinheiro vivo", "healthDelta": 0, "happinessDelta": 0, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 0, "reputationDelta": 0, "moneyDelta": 10, "resultText": "Você guardou a nota de dez reais no bolso com responsabilidade."}
        ]
    },
    {
        "id": "luck_flat_tire_storm",
        "category": "azar",
        "minAge": 18, "maxAge": 75,
        "title": "Pneu Furado na Tempestade",
        "description": "Voltando para casa à noite sob forte temporal, um dos pneus estoura em uma poça funda.",
        "choices": [
            {"label": "Trocar o estepe na chuva com calma e atenção", "healthDelta": -5, "happinessDelta": 5, "smartsDelta": 15, "looksDelta": -5, "karmaDelta": 5, "stressDelta": 15, "reputationDelta": 10, "moneyDelta": -120, "resultText": "Você ficou ensopado, mas trocou o pneu como um verdadeiro sobrevivente!"},
            {"label": "Chamar o guincho do seguro e esperar no carro quentinho", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -5, "reputationDelta": 5, "moneyDelta": -50, "resultText": "O resgate chegou rápido e você voltou em segurança para casa."}
        ]
    },
    {
        "id": "lottery_mega_jackpot_dream",
        "category": "loteria",
        "minAge": 18, "maxAge": 85,
        "title": "O Bolão Acumulado da Firma",
        "description": "A Mega-Sena fictícia acumulou em 80 milhões de reais e seus colegas estão montando um bolão oficial.",
        "choices": [
            {"label": "Entrar no bolão com R$ 100", "healthDelta": 0, "happinessDelta": 20, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 5, "reputationDelta": 10, "moneyDelta": 450, "resultText": "O bolão acertou a quadra! Cada participante recebeu R$ 550 limpos!"},
            {"label": "Não entrar no bolão e dizer que loteria é ilusão", "healthDelta": 0, "happinessDelta": 0, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 0, "reputationDelta": -5, "moneyDelta": 0, "resultText": "Você economizou os R$ 100 e continuou com seu planejamento."}
        ]
    },

    # 10. ESCOLHAS MORAIS & CRIMES
    {
        "id": "moral_wallet_found",
        "category": "escolhas morais",
        "minAge": 12, "maxAge": 80,
        "title": "A Carteira no Banco da Praça",
        "description": "Você encontra uma carteira de couro recheada com R$ 2.400 em dinheiro vivo e cartões de um senhor idoso.",
        "choices": [
            {"label": "Localizar o dono pelo documento e devolver tudo", "healthDelta": 5, "happinessDelta": 30, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 35, "stressDelta": -15, "reputationDelta": 30, "moneyDelta": 300, "resultText": "O idoso chorou de alívio por recuperar sua aposentadoria e insistiu em te dar R$ 300 de gratidão!"},
            {"label": "Ficar com o dinheiro e jogar os documentos fora", "healthDelta": 0, "happinessDelta": -10, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": -40, "stressDelta": 25, "reputationDelta": -20, "moneyDelta": 2400, "resultText": "Seu saldo bancário subiu, mas o carma pesou e a sensação de culpa é amarga."}
        ]
    },
    {
        "id": "crime_stolen_phone_fence",
        "category": "crimes",
        "minAge": 16, "maxAge": 60,
        "title": "O Celular Suspeito no Beco",
        "description": "Um indivíduo misterioso te oferece o smartphone mais moderno do ano, lacrado na caixa, por apenas R$ 400.",
        "choices": [
            {"label": "Recusar imediatamente e se afastar", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 15, "looksDelta": 0, "karmaDelta": 25, "stressDelta": -10, "reputationDelta": 15, "moneyDelta": 0, "resultText": "Minutos depois a viatura da polícia enquadrou o sujeito ali perto. Você escapou de uma fria!"},
            {"label": "Comprar o aparelho achando que fez o melhor negócio do mundo", "healthDelta": -10, "happinessDelta": -25, "smartsDelta": -15, "looksDelta": 0, "karmaDelta": -35, "stressDelta": 35, "reputationDelta": -30, "moneyDelta": -400, "resultText": "O aparelho foi rastreado pela polícia e você teve que depor na delegacia por receptação."}
        ]
    },

    # 11. HOBBIES & REDES SOCIAIS
    {
        "id": "hobbies_guitar_stage",
        "category": "hobbies",
        "minAge": 14, "maxAge": 70,
        "title": "A Noite de Microfone Aberto",
        "description": "O bar cultural do bairro abriu o palco para apresentações musicais amadoras.",
        "choices": [
            {"label": "Subir no palco com violão e cantar sua música autoral", "healthDelta": 5, "happinessDelta": 35, "smartsDelta": 10, "looksDelta": 15, "karmaDelta": 10, "stressDelta": -20, "reputationDelta": 30, "moneyDelta": 0, "resultText": "A plateia cantou o refrão junto e aplaudiu de pé! Sua autoestima foi nas nuvens!"},
            {"label": "Assistir da mesa comendo petiscos", "healthDelta": 0, "happinessDelta": 15, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": 5, "stressDelta": -10, "reputationDelta": 5, "moneyDelta": -45, "resultText": "Uma noite deliciosa e descontraída com boa música ao vivo."}
        ]
    },
    {
        "id": "social_viral_tiktok",
        "category": "redes sociais",
        "minAge": 12, "maxAge": 50,
        "title": "O Vídeo Engraçado",
        "description": "Um vídeo seu fazendo uma receita que deu completamente errado começou a explodir no TikTok e Instagram.",
        "choices": [
            {"label": "Entrar na onda e postar bastidores com carisma", "healthDelta": 0, "happinessDelta": 25, "smartsDelta": 5, "looksDelta": 10, "karmaDelta": 5, "stressDelta": 5, "reputationDelta": 35, "moneyDelta": 2000, "resultText": "Você ganhou 100 mil seguidores e fechou parcerias com marcas conceituadas!"},
            {"label": "Ficar com vergonha e apagar o vídeo", "healthDelta": 0, "happinessDelta": -5, "smartsDelta": 5, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -5, "reputationDelta": -10, "moneyDelta": 0, "resultText": "A poeira baixou, mas você perdeu a chance dos 15 minutos de fama."}
        ]
    },

    # 12. IMIGRAÇÃO, POLÍTICA, NEGÓCIOS & FAMA
    {
        "id": "immig_overseas_offer",
        "category": "imigração",
        "minAge": 22, "maxAge": 55,
        "title": "Convite para Morar no Exterior",
        "description": "Uma empresa internacional gostou do seu perfil no LinkedIn e ofereceu visto de trabalho em Portugal.",
        "choices": [
            {"label": "Fazer as malas e viver essa grande experiência cultural", "healthDelta": 10, "happinessDelta": 30, "smartsDelta": 25, "looksDelta": 10, "karmaDelta": 10, "stressDelta": 10, "reputationDelta": 30, "moneyDelta": 12000, "resultText": "Você desembarcou em Lisboa! Uma nova etapa emocionante e rica da sua história começou."},
            {"label": "Ficar no Brasil perto dos amigos e da família querida", "healthDelta": 5, "happinessDelta": 20, "smartsDelta": 10, "looksDelta": 0, "karmaDelta": 15, "stressDelta": -15, "reputationDelta": 15, "moneyDelta": 0, "resultText": "O carinho dos seus entes queridos vale mais do que qualquer moeda estrangeira."}
        ]
    },
    {
        "id": "politics_community_leader",
        "category": "política",
        "minAge": 25, "maxAge": 70,
        "title": "A Associação de Moradores do Bairro",
        "description": "Os vizinhos estão impressionados com seu senso de justiça e pedem que você lidere a associação comunitária.",
        "choices": [
            {"label": "Aceitar e lutar por melhorias na praça e segurança", "healthDelta": 0, "happinessDelta": 25, "smartsDelta": 20, "looksDelta": 5, "karmaDelta": 35, "stressDelta": 10, "reputationDelta": 40, "moneyDelta": 0, "resultText": "A praça foi revitalizada, ganhou lâmpadas LED e seu nome foi gravado na placa inaugural!"},
            {"label": "Agradecer e recusar para ter mais tempo livre", "healthDelta": 0, "happinessDelta": 5, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 0, "stressDelta": -10, "reputationDelta": 0, "moneyDelta": 0, "resultText": "Eles compreenderam seus motivos e outro vizinho assumiu o cargo."}
        ]
    },
    {
        "id": "biz_startup_pitch",
        "category": "negócios",
        "minAge": 22, "maxAge": 60,
        "title": "O Pitch para Investidores-Anjo",
        "description": "Você tem a oportunidade de apresentar seu plano de negócios inovador para um grupo de investidores sérios.",
        "choices": [
            {"label": "Apresentar números sólidos e protótipo funcional", "healthDelta": -5, "happinessDelta": 30, "smartsDelta": 25, "looksDelta": 10, "karmaDelta": 10, "stressDelta": 10, "reputationDelta": 30, "moneyDelta": 25000, "resultText": "Os investidores adoraram o projeto e aportaram R$ 25.000 de capital inicial!"},
            {"label": "Desistir por medo de falhar", "healthDelta": 0, "happinessDelta": -15, "smartsDelta": 0, "looksDelta": 0, "karmaDelta": 0, "stressDelta": 10, "reputationDelta": -5, "moneyDelta": 0, "resultText": "A oportunidade passou e outro competidor lançou a mesma ideia."}
        ]
    },
    {
        "id": "fame_tv_interview",
        "category": "fama",
        "minAge": 18, "maxAge": 65,
        "title": "Entrevista no Programa de Televisão",
        "description": "Um famoso apresentador te convida para ser entrevistado ao vivo no programa de maior audiência da tarde.",
        "choices": [
            {"label": "Ir bem vestido, demonstrar carisma e sabedoria", "healthDelta": 5, "happinessDelta": 35, "smartsDelta": 15, "looksDelta": 20, "karmaDelta": 15, "stressDelta": 5, "reputationDelta": 45, "moneyDelta": 3500, "resultText": "O programa foi recorde de audiência e você foi ovacionado nas redes do país inteiro!"},
            {"label": "Fazer comentários polêmicos e sem noção", "healthDelta": -5, "happinessDelta": -20, "smartsDelta": -15, "looksDelta": -10, "karmaDelta": -25, "stressDelta": 30, "reputationDelta": -35, "moneyDelta": 1000, "resultText": "Você virou meme de chacota e sofreu cancelamento em massa na internet."}
        ]
    },
    {
        "id": "crisis_inflation_spike",
        "category": "crises",
        "minAge": 18, "maxAge": 80,
        "title": "A Disparada da Inflação",
        "description": "Os preços dos alimentos e do combustível subiram 15% nos últimos meses em todo o país.",
        "choices": [
            {"label": "Cortar supérfluos e renegociar contratos de serviços", "healthDelta": 0, "happinessDelta": 10, "smartsDelta": 20, "looksDelta": 0, "karmaDelta": 5, "stressDelta": -10, "reputationDelta": 10, "moneyDelta": 500, "resultText": "Seu planejamento financeiro impecável manteve suas contas no azul sem sufoco!"},
            {"label": "Continuar gastando no cartão de crédito rotativo", "healthDelta": -10, "happinessDelta": -20, "smartsDelta": -15, "looksDelta": 0, "karmaDelta": -5, "stressDelta": 30, "reputationDelta": -15, "moneyDelta": -2500, "resultText": "A bola de neve de juros cobrou caro e seu nome foi parar no Serasa."}
        ]
    },
    {
        "id": "opp_tech_bootcamp",
        "category": "oportunidades",
        "minAge": 16, "maxAge": 55,
        "title": "Bolsa Integral em Bootcamp Tecnológico",
        "description": "Você foi selecionado entre milhares de candidatos para uma bolsa completa em um curso intensivo de Inteligência Artificial.",
        "choices": [
            {"label": "Mergulhar de cabeça nas aulas e criar projetos práticos", "healthDelta": -5, "happinessDelta": 30, "smartsDelta": 35, "looksDelta": 0, "karmaDelta": 10, "stressDelta": 10, "reputationDelta": 25, "moneyDelta": 1500, "resultText": "Você se formou com honras e começou a receber propostas de grandes empresas de tech!"},
            {"label": "Desperdiçar a vaga por preguiça de estudar", "healthDelta": 0, "happinessDelta": -10, "smartsDelta": -10, "looksDelta": 0, "karmaDelta": -10, "stressDelta": 0, "reputationDelta": -15, "moneyDelta": 0, "resultText": "A bolsa foi repassada para outro estudante da lista de espera."}
        ]
    }
]

with open("assets/data/events.json", "w", encoding="utf-8") as f:
    json.dump(events, f, ensure_ascii=False, indent=2)

print(f"Successfully generated {len(events)} events covering all requested categories!")
