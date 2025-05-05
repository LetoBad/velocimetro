// Importação dos pacotes necessários
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocimetro/viewmodels/viagem_viewmodel.dart';
import 'package:velocimetro/widgets/velocimetro_widget.dart';

// Tela principal do app (Home)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa o ViewModel e solicita permissões de localização logo após o carregamento da tela
    Future.delayed(Duration.zero, () {
      Provider.of<ViagemViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fundo branco
      appBar: AppBar(
        title: const Text(
          'Velocímetro',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Título preto
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // AppBar branca
        elevation: 0, // Sem sombra
        centerTitle: true, // Título centralizado
      ),

      // Consumer para escutar o TripViewModel
      body: Consumer<ViagemViewModel>(
        builder: (context, ViagemViewModel, child) {
          // Se não tiver permissão de localização, exibe aviso
          if (!ViagemViewModel.permissaoLocalizacao) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_disabled,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Permissão de localização necessária',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    // Solicita permissão novamente
                    onPressed: () => ViagemViewModel.solicitarPermissaoLocalizacao(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Solicitar Permissão'),
                  ),
                ],
              ),
            );
          }

          // Se tiver permissão, exibe os dados do velocímetro e viagem
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Velocímetro (componente customizado)
                      VelocimetroWidget(
                        velocidade: ViagemViewModel.velocidade,
                        velocidadeMax: 180,
                      ),

                      const SizedBox(height: 30),

                      // Cartões de distância e velocidade média
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            _infoCard(
                              'Distância',
                              '${ViagemViewModel.distancia.toStringAsFixed(2)} km',
                              Icons.straighten,
                              Colors.green.shade400,
                            ),
                            const SizedBox(width: 20),
                            _infoCard(
                              'Vel. Média',
                              '${ViagemViewModel.velocidade.toStringAsFixed(1)} km/h',
                              Icons.speed,
                              Colors.orange.shade400,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Cartão de tempo total da viagem
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _infoCard(
                          'Tempo',
                          _formatarDuracao(ViagemViewModel.duracaoViagem),
                          Icons.timer,
                          Colors.blue.shade400,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botões de controle (play/pause e reset)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255), // Fundo branco
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5), // Sombra pra cima
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão de iniciar ou pausar rastreamento
                    _actionButton(
                      ViagemViewModel.rastreamentoAtivo ? Icons.pause : Icons.play_arrow,
                      ViagemViewModel.rastreamentoAtivo ? Colors.orange : const Color.fromARGB(255, 0, 0, 0),
                      () {
                        if (ViagemViewModel.rastreamentoAtivo) {
                          ViagemViewModel.pausarRastreamento();
                        } else {
                          ViagemViewModel.iniciarViagem();
                        }
                      },
                    ),

                    // Botão para resetar os dados
                    _actionButton(
                      Icons.refresh,
                      const Color.fromARGB(255, 0, 0, 0),
                      () => ViagemViewModel.retomarRastreamento(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Componente reutilizável para mostrar dados da viagem (distância, tempo, etc.)
  Widget _infoCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(179, 255, 255, 255),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botão com apenas ícone clicável
  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color,
        size: 30,
      ),
    );
  }

  // Função utilitária para formatar o tempo da viagem como hh:mm:ss
  String _formatarDuracao(Duration duration) {
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    String horas = doisDigitos(duration.inHours);
    String minutos = doisDigitos(duration.inMinutes.remainder(60));
    String segundos = doisDigitos(duration.inSeconds.remainder(60));
    return '$horas:$minutos:$segundos';
  }
}
