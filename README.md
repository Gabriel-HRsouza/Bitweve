# BitWeve Ultimate — Simulador de Vida Real

<p align="center">
  <img src="assets/icons/logo.png" width="128" height="128" alt="BitWeve Logo" />
</p>

<p align="center">
  <b>Simulador de vida profundo, 100% interativo, visualmente profissional e offline para Android e iOS.</b><br/>
  Desenvolvido em Flutter e Dart com persistência local em SQLite nativo (Drift).
</p>

<p align="center">
  <a href="https://github.com/Gabriel-HRsouza/Bitweve/raw/main/release/BitWeve-v1.0.0.apk">
    <img src="https://img.shields.io/badge/Download_APK-Direto_(v1.0.0)-00F2FE?style=for-the-badge&logo=android&logoColor=black" alt="Download APK Direto" />
  </a>
  <a href="https://github.com/Gabriel-HRsouza/Bitweve/releases">
    <img src="https://img.shields.io/badge/GitHub-Releases-10B981?style=for-the-badge&logo=github&logoColor=white" alt="Releases" />
  </a>
</p>

---

## 📱 Como Baixar e Instalar no Celular Android

### Método Recomendado: Download Direto (Super Fácil)
1. **Baixe o arquivo diretamente no seu celular:**  
   👉 **[Clique aqui para Baixar o BitWeve v1.0.0 APK](https://github.com/Gabriel-HRsouza/Bitweve/raw/main/release/BitWeve-v1.0.0.apk)**  
   *(Também disponível na pasta `release/BitWeve-v1.0.0.apk` neste repositório ou na aba [Releases](https://github.com/Gabriel-HRsouza/Bitweve/releases))*.
2. Ao concluir o download, abra o arquivo baixado (`BitWeve-v1.0.0.apk`) pela barra de notificações ou pelo gerenciador de arquivos do celular.
3. Se o Android solicitar autorização para instalar de fontes desconhecidas pelo navegador, toque em **Permitir desta fonte**.
4. Toque em **Instalar** e abra o jogo! Todos os sistemas funcionam 100% offline e gratuitamente.

*Observação para desenvolvedores:* Caso clone o código e compile manualmente, o instalador gerado ficará em:  
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
- **Motor Central de Envelhecimento**: O botão de avançar um ano calcula passagem de tempo, salários, despesas, impostos, saúde, estresse, reputação e eventos aleatórios com efeitos sonoros hápticos e sonoros em todos os botões.
- **Saúde Avançada & Neurodesenvolvimento**: Representação clínica individualizada de TEA, TDAH, Dislexia, Depressão, Ansiedade, Bipolaridade, Diabetes, Asma e Hipertensão. Acesso ao SUS, planos de saúde particulares, consultas com especialistas, psicoterapia e farmácia.
- **Mercado Cripto & Bolsa**: Gráficos dinâmicos interativos com Bitcoin (BTC), Ethereum (ETH) e BitWeve Token (BWV), com ordens de compra e venda em tempo real e volatilidade calculada anualmente.
- **Concessionária & Garagem**: Catálogo completo com motocicletas, sedãs, SUVs blindados, esportivos, iates e jatos, com gestão de manutenção anual, seguros e revenda.
- **Empreendedorismo & Startups**: Fundação de empresas de tecnologia, restaurantes e agências. Contratação de equipes, investimentos em marketing, valuation dinâmico e realização de lucro via venda da empresa (Exit).
- **Submundo, Crimes & Justiça**: Ações narrativas de risco, mandados de prisão em flagrante, antecedentes criminais e contratação de bancas de advogados para anulação de sentenças.
- **Modo Deus Gratuito (God Mode)**: Painel acessível pelo ícone de raio dourado na AppBar para injeção de fundos, manipulação livre de atributos, milagre da cura total, indulto judicial e vitória garantida na loteria.
- **Avatar Dinâmico com Expressões**: Sistema próprio de avatar vetorial procedural que reflete as emoções do protagonista (felicidade, tristeza, raiva, surpresa, doença, amor e medo).
- **Relações Familiares e NPCs Autônomos**: Pais, parentes e amigos envelhecem de forma sincronizada com o protagonista, possuem profissões e emoções próprias, e reagem a interações.
- **Morte e Modo Dinastia**: Ao falecer, o jogador pode visualizar o epitáfio completo da vida e continuar jogando como herdeiro direto para perpetuar o patrimônio da família por gerações.
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
