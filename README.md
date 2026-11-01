# BitWeve

Simulador de vida interativo para dispositivos móveis, desenvolvido em Flutter e Dart. O projeto foca em simulação profunda baseada em decisões textuais e dinâmicas, com identidade visual própria, motor de eventos procedurais e persistência local completa.

Todos os recursos do jogo são totalmente gratuitos e desbloqueados, sem moedas pagas, assinaturas ou microtransações.

---

## Como Baixar e Instalar o Jogo

### No Android

#### Método 1: Instalação Direta via APK (Recomendado)
1. Baixe o instalador oficial diretamente: [Baixar BitWeve v1.0.0 (APK)](https://github.com/Gabriel-HRsouza/Bitweve/releases/download/v1.0.0/BitWeve-v1.0.0.apk) ou acesse a página de [Releases](https://github.com/Gabriel-HRsouza/Bitweve/releases).
2. No seu celular Android, abra o arquivo baixado (`BitWeve-v1.0.0.apk`).
3. Se o sistema solicitar, autorize a instalação de aplicativos de fontes desconhecidas para o navegador ou gerenciador de arquivos.
4. Toque em **Instalar** e abra o jogo quando o processo for concluído.

*Observação para desenvolvedores:* Caso você clone o código e compile manualmente, o instalador gerado ficará em:
`build/app/outputs/flutter-apk/app-release.apk`

---

### No iOS (iPhone / iPad)

Devido às políticas e certificados exigidos pela Apple, aplicativos fora da App Store precisam ser compilados ou distribuídos via TestFlight ou ferramentas de assinatura pessoal.

#### Opção A: Compilar via Xcode (para desenvolvedores ou com Mac)
1. Clone este repositório no seu Mac:
   ```bash
   git clone https://github.com/Gabriel-HRsouza/Bitweve.git
   cd Bitweve
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Abra o projeto no Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. Na aba **Signing & Capabilities**, selecione seu **Team** (conta gratuita de desenvolvedor Apple).
5. Conecte seu iPhone via cabo ou Wi-Fi e clique no botão **Run** (Play) no Xcode para instalar diretamente no aparelho.

#### Opção B: Instalação via TestFlight / AltStore
Se você utiliza AltStore ou Sideloadly no Windows ou Mac:
1. Gere o pacote de compilação sem assinatura:
   ```bash
   flutter build ios --release --no-codesign
   ```
2. Empacote o arquivo `Runner.app` em formato `.ipa`.
3. Envie para o dispositivo através do AltStore ou Sideloadly com seu Apple ID pessoal.

---

## Principais Sistemas do Jogo

- **Persistência Local Real**: O jogo utiliza SQLite nativo via Drift. Todo o progresso fica salvo na memória privada do celular, mantendo as vidas e decisões salvas após fechar ou reiniciar o aparelho. Os dados só são apagados se o aplicativo for desinstalado.
- **Motor Central de Envelhecimento**: O botão de avançar um ano calcula passagem de tempo, salários, despesas, impostos, saúde, estresse, reputação e eventos aleatórios.
- **Avatar Dinâmico com Expressões**: Sistema próprio de avatar vetorial procedural que reflete as emoções do protagonista (felicidade, tristeza, raiva, surpresa, doença, amor e medo).
- **Relações Familiares e NPCs**: Pais, parentes e amigos envelhecem de forma sincronizada com o protagonista, possuem profissões e emoções próprias, e reagem a conversas, elogios e presentes.
- **Educação e Carreira**: Passagem escolar, vestibulares para cursos de ensino superior e mercado de trabalho com dezenas de profissões nas áreas de tecnologia, medicina, direito, segurança pública, negócios e artes.
- **Economia e Investimentos**: Carteira de investimentos com ativos de baixo, médio e alto risco (Renda Fixa, Ações e Criptomoedas), compra de imóveis e aquisição de veículos com custos de manutenção anual.
- **Morte e Modo Dinastia**: Ao falecer, o jogador pode visualizar o epitáfio completo da vida e, caso tenha filhos, continuar jogando com o herdeiro para manter o patrimônio da família por gerações.
- **Múltiplos Saves**: Gerenciador de vidas que permite criar e alternar entre diferentes personagens a qualquer momento.

---

## Estrutura da Arquitetura

O projeto foi organizado segundo os padrões de Clean Architecture modular:

- `lib/core/database/`: Definições das tabelas relacionais do Drift e serviço de persistência transacional SQLite.
- `lib/core/router/`: Configuração de navegação declarativa com GoRouter.
- `lib/core/theme/`: Sistema de cores, tipografia (Outfit) e temas claro e escuro.
- `lib/core/audio/`: Controle de efeitos sonoros, feedback tátil e preferências de som.
- `lib/features/character/`: Modelagem de atributos, criação de personagem e renderização vetorial de avatares.
- `lib/features/life_engine/`: Motor central de vida, cálculo de probabilidades, histórico e envelhecimento.
- `lib/features/relationships/`: Gestão de NPCs, interações e dinâmicas familiares.
- `lib/features/education/`: Escolas, cursos universitários e diplomas.
- `lib/features/careers/`: Ocupações, entrevistas, aumentos e promoções.
- `lib/features/finances/`: Saldo bancário, fluxo de caixa e cotações de investimentos.
- `lib/features/properties/`: Inventário de bens, imóveis e veículos.
- `lib/features/events/`: Repositório de eventos aleatórios e ramificações de escolha.
- `lib/features/settings/`: Gerenciador de múltiplos arquivos de save e configurações gerais.

---

## Como Rodar em Ambiente de Desenvolvimento

### Pré-requisitos
- Flutter SDK (versão 3.20 ou superior)
- Dart SDK (versão 3.4 ou superior)
- Android Studio ou VS Code configurado

### Passos
1. Clone o repositório:
   ```bash
   git clone https://github.com/Gabriel-HRsouza/Bitweve.git
   cd Bitweve
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Gere os códigos do banco de dados (Drift):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Execute o projeto:
   ```bash
   flutter run
   ```

5. Para rodar os testes automatizados:
   ```bash
   flutter test
   ```

---

## Licença

Projeto desenvolvido para fins de entretenimento e simulação interativa. Todos os direitos reservados.
