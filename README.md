# 📚 GUIA COMPLETO: APP DE TELEMETRIA COM CLEAN ARCHITECTURE

## 🎯 O QUE FIZEMOS?

Criamos um app Flutter de telemetria em tempo real seguindo **Clean Architecture**, 
construindo camada por camada, do núcleo para fora.

---

## 📐 ARQUITETURA: AS 3 CAMADAS

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌───────────┐  ┌──────────┐  ┌────────────────────────┐  │
│  │  Screen   │  │ Provider │  │  Widgets Reutilizáveis │  │
│  │  (UI)     │  │ (Estado) │  │  (Cards)               │  │
│  └───────────┘  └──────────┘  └────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↓ depende de ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │ Entities  │  │  Repository  │  │   Use Cases      │    │
│  │ (Modelos) │  │  Interface   │  │  (Casos de Uso)  │    │
│  └───────────┘  └──────────────┘  └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           ↑ implementa ↑
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌──────────────┐  ┌──────────────────────────────────┐    │
│  │ Data Sources │  │  Repository Implementation       │    │
│  │ (GPS, Sensor)│  │  (Combina fontes de dados)      │    │
│  └──────────────┘  └──────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 ORDEM DE CONSTRUÇÃO (DO NÚCLEO PARA FORA)

### ✅ 1. DOMAIN LAYER (Núcleo - Independente)

**Por que começamos aqui?**
- É independente: não depende de nada
- Define os "contratos" que todo o resto segue
- Pode ser testado isoladamente

#### 📦 1.1 Entities (Entidades)
- **Arquivo:** `lib/features/telemetry/domain/entities/telemetry_data.dart`
- **O que é:** Modelo de negócio puro
- **Contém:** 
  - Dados de GPS (lat, lng, speed, altitude, etc)
  - Dados de sensores (acelerômetro, giroscópio, magnetômetro)
  - Lógica de negócio (cálculo de magnitude, conversão km/h)

#### 📋 1.2 Repository Interface
- **Arquivo:** `lib/features/telemetry/domain/repositories/telemetry_repository.dart`
- **O que é:** Contrato abstrato (interface)
- **Define:**
  - `startTracking()` - iniciar rastreamento
  - `stopTracking()` - parar rastreamento
  - `getTelemetryStream()` - stream de dados
  - `checkPermissions()` / `requestPermissions()` - permissões

#### 🎯 1.3 Use Cases (Casos de Uso)
- **Arquivos:**
  - `start_tracking.dart` - Iniciar rastreamento
  - `stop_tracking.dart` - Parar rastreamento
  - `get_telemetry_stream.dart` - Obter stream de dados
- **O que são:** Cada ação específica que o usuário pode fazer
- **Vantagem:** Single Responsibility, fácil de testar

---

### ✅ 2. DATA LAYER (Implementações)

**Por que agora?**
- Implementa os contratos do Domain
- Conhece detalhes técnicos (pacotes, APIs)

#### 🔌 2.1 Data Sources (Fontes de Dados)
- **Location Data Source** (`location_data_source.dart`)
  - Usa pacote `geolocator`
  - Gerencia GPS e permissões
  - Retorna stream de Position
  
- **Sensor Data Source** (`sensor_data_source.dart`)
  - Usa pacote `sensors_plus`
  - Acessa acelerômetro, giroscópio, magnetômetro
  - Retorna streams de cada sensor

#### 🔄 2.2 Repository Implementation
- **Arquivo:** `telemetry_repository_impl.dart`
- **O que faz:**
  - **COMBINA** dados de GPS + 3 sensores
  - Gerencia múltiplos streams simultaneamente
  - Cache dos últimos valores de cada fonte
  - Emite objetos `TelemetryData` completos
- **Estratégia:** Só emite quando tem dados essenciais (GPS + acelerômetro)

---

### ✅ 3. PRESENTATION LAYER (Interface com Usuário)

**Por que por último?**
- Depende das outras camadas
- Consome os Use Cases
- Não contém lógica de negócio

#### 🎨 3.1 Provider (Gerenciador de Estado)
- **Arquivo:** `telemetry_provider.dart`
- **Padrão:** ChangeNotifier (Provider)
- **Responsabilidades:**
  - Manter estado atual (dados, tracking, erros)
  - Chamar use cases
  - Notificar UI quando algo muda (`notifyListeners()`)
- **Métodos públicos:**
  - `checkAndRequestPermissions()`
  - `startTracking()`
  - `stopTracking()`
  - `toggleTracking()`

#### 🧩 3.2 Widgets Reutilizáveis
- **Arquivo:** `telemetry_info_card.dart`
- **O que é:** Card informativo reutilizável
- **Props:** title, value, icon, color
- **Uso:** Exibir cada dado de telemetria de forma consistente

#### 📱 3.3 Screen (Tela)
- **Arquivo:** `telemetry_screen.dart`
- **O que faz:**
  - Usa `Consumer<TelemetryProvider>` para escutar mudanças
  - Exibe diferentes estados (loading, erro, dados)
  - Grid de cards com todos os dados
  - FAB para iniciar/parar

---

## 🔗 FLUXO DE DADOS

```
┌──────────────┐
│   USUÁRIO    │ Toca no botão "Iniciar"
└──────┬───────┘
       ↓
┌──────────────┐
│    Screen    │ Chama provider.startTracking()
└──────┬───────┘
       ↓
┌──────────────┐
│   Provider   │ Chama startTrackingUseCase()
└──────┬───────┘
       ↓
┌──────────────┐
│  Use Case    │ Chama repository.startTracking()
└──────┬───────┘
       ↓
┌──────────────────┐
│   Repository     │ Inicia Data Sources
│  Implementation  │
└──────┬───────────┘
       ↓
┌──────────────────┐
│  Data Sources    │ GPS + Sensores começam a emitir dados
└──────┬───────────┘
       ↓
┌──────────────────┐
│   Repository     │ Combina dados → emite TelemetryData
│  Implementation  │
└──────┬───────────┘
       ↓
┌──────────────┐
│  Use Case    │ Repassa stream
└──────┬───────┘
       ↓
┌──────────────┐
│   Provider   │ Atualiza estado → notifyListeners()
└──────┬───────┘
       ↓
┌──────────────┐
│    Screen    │ Rebuild automático → exibe novos dados
└──────────────┘
```

---

## 🎓 CONCEITOS IMPORTANTES

### 1️⃣ INVERSÃO DE DEPENDÊNCIA
- Domain define interface → Data implementa
- Camadas superiores dependem de abstrações, não de implementações
- Facilita testes e troca de implementações

### 2️⃣ SINGLE RESPONSIBILITY
- Cada classe tem UMA responsabilidade
- Use Case = uma ação
- Data Source = uma fonte de dados
- Entity = um modelo de negócio

### 3️⃣ STREAMS
- "Rio de dados" que flui continuamente
- Perfeito para dados em tempo real
- UI "escuta" (listen) e reage a cada novo dado

### 4️⃣ PROVIDER PATTERN
- Gerenciamento de estado reativo
- `notifyListeners()` → widgets se rebuildam automaticamente
- `Consumer<T>` → escuta mudanças no provider

### 5️⃣ INJEÇÃO DE DEPENDÊNCIAS
- Passa dependências via construtor
- Facilita testes (pode passar mocks)
- Desacopla classes

---

## 📊 VANTAGENS DESTA ARQUITETURA

✅ **Testabilidade**
- Cada camada pode ser testada isoladamente
- Fácil criar mocks

✅ **Manutenibilidade**
- Código organizado e fácil de encontrar
- Mudanças são localizadas

✅ **Escalabilidade**
- Fácil adicionar novos features
- Padrão consistente

✅ **Independência**
- Domain não conhece detalhes de implementação
- Pode trocar GPS por outra API sem mudar domain

✅ **Reusabilidade**
- Use Cases podem ser reutilizados
- Widgets são componentizados

---

## 🚀 COMO TESTAR

1. **Execute o app:**
   ```
   flutter run
   ```

2. **Permita localização** quando solicitado

3. **Toque em "Iniciar"** - verá os dados aparecerem em tempo real

4. **Mova o dispositivo** - sensores mostrarão mudanças

5. **Caminhe com o celular** - GPS atualizará posição e velocidade

---

## 📦 PACOTES UTILIZADOS

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0           # Gerenciamento de estado
  geolocator: ^10.0.0        # GPS
  sensors_plus: ^3.0.0       # Acelerômetro, giroscópio, magnetômetro
```

---

## 🎯 RESUMO DA ORDEM DE CONSTRUÇÃO

1. ✅ Domain/Entities → Modelo de negócio
2. ✅ Domain/Repository Interface → Contrato
3. ✅ Domain/Use Cases → Ações
4. ✅ Data/Data Sources → Fontes reais
5. ✅ Data/Repository Impl → Combina fontes
6. ✅ Presentation/Provider → Estado
7. ✅ Presentation/Widgets → Componentes UI
8. ✅ Presentation/Screen → Tela principal
9. ✅ main.dart → DI e setup

---

## 💡 PRÓXIMOS PASSOS (Para Melhorar)

- [ ] Adicionar testes unitários
- [ ] Adicionar Google Maps para visualizar rota
- [ ] Salvar histórico de telemetria (banco de dados local)
- [ ] Exportar dados para CSV/JSON
- [ ] Adicionar gráficos em tempo real
- [ ] Notificações quando velocidade excede limite

---

**🎉 Parabéns! Você construiu um app completo com Clean Architecture!**
