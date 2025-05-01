```markdown
# realtime_image_labeler

[![pub package](https://img.shields.io/pub/v/realtime_image_labeler.svg)](https://pub.dev/packages/realtime_image_labeler)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/[SEU_USUARIO_GITHUB]/realtime_image_labeler/blob/main/LICENSE) <!-- ATUALIZE O LINK DO GITHUB -->

Um widget Flutter que fornece uma visualização de câmera ao vivo para detecção de objetos em tempo real usando um modelo SSD MobileNet TFLite embutido. Ele exibe caixas delimitadoras com rótulos e pontuações de confiança para objetos detectados e oferece uma interface simples para integração.

**(Ver Versão em Inglês [README.md](README.md))**

## Pré-visualização

**(ADICIONE UM SCREENSHOT OU GIF AQUI!)**

*Exemplo:*
`![Preview do Widget](preview.gif)`

*Um GIF demonstrando a detecção em tempo real é altamente recomendado.*

## Funcionalidades

*   Exibe um preview da câmera ao vivo em tela cheia.
*   Realiza detecção de objetos em tempo real usando o modelo SSD MobileNet TFLite incluído.
*   Desenha caixas delimitadoras (bounding boxes) e rótulos ao redor dos objetos detectados.
*   Fornece resultados da detecção através do callback `onResult` (inclui rótulo, confiança, localização).
*   Opcionalmente, inclui um botão personalizável para capturar fotos (callback `onTakePicture`).
*   Gerencia internamente a inicialização da câmera e o ciclo de vida.

## Começando

1.  **Adicionar Dependência:** Adicione isto ao arquivo `pubspec.yaml` do seu projeto:
    ```yaml
    dependencies:
      realtime_image_labeler: ^0.0.1 # Substitua pela versão mais recente publicada
    ```

2.  **Instalar:** Execute `flutter pub get` no seu terminal.

## Configuração da Plataforma (Permissões)

O acesso à câmera requer configuração específica da plataforma.

**Android** (`android/app/src/main/AndroidManifest.xml`)

Adicione a seguinte permissão *antes* da tag `<application>`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<!-- Opcional, mas recomendado -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
Use code with caution.
iOS (ios/Runner/Info.plist)
Adicione o seguinte par chave-string dentro da tag principal <dict>:
<key>NSCameraUsageDescription</key>
<string>Este aplicativo precisa de acesso à câmera para realizar detecção de objetos ao vivo.</string>
Use code with caution.
Xml
(Lembre-se de fornecer uma descrição clara do uso para seus usuários).
Observação: Embora este widget gerencie a inicialização da câmera, você ainda pode querer solicitar a permissão da câmera antes de navegar para a tela que contém o DetectorWidget, usando um pacote como permission_handler para uma experiência de usuário mais suave.
Uso Básico
Importe o pacote e integre o DetectorWidget em sua tela.
import 'package:flutter/material.dart';
import 'package:realtime_image_labeler/realtime_image_labeler.dart'; // Importe o pacote
import 'dart:io'; // Necessário para operações com File se usar onTakePicture
import 'package:camera/camera.dart'; // Necessário para XFile

class TelaDeteccao extends StatelessWidget {
  const TelaDeteccao({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detecção de Objetos em Tempo Real')),
      body: DetectorWidget(
        // Callback obrigatório para os resultados da detecção
        onResult: (List<Recognition> results) {
          // Processa a lista de objetos detectados (Recognition)
          // Cada objeto 'Recognition' contém rótulo, score de confiança
          // e localização (bounding box).
          if (results.isNotEmpty) {
            // Exemplo: Imprime o rótulo e confiança do primeiro objeto detectado
            final firstResult = results.first;
            print(
                "Detectado: ${firstResult.label} (${(firstResult.score * 100).toStringAsFixed(0)}%)");
          }
          // Considere atualizar sua UI com base nos resultados aqui
        },

        // Callback opcional para quando uma foto é tirada
        onTakePicture: (XFile file) {
          print('Foto capturada: ${file.path}');

          // Exemplo: Navega para uma nova tela para exibir a foto
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => TelaExibirFoto(imagePath: file.path),
          //   ),
          // );

          // Ou exibe em um diálogo:
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Foto Capturada"),
              content: Image.file(File(file.path)), // Requer 'dart:io'
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop, child: Text("OK"))
              ],
            ),
          );
        },

        // --- Estilização Opcional ---
        // iconSize: 70,
        // icon: Icons.camera_alt,
        // backgroundColor: Colors.blue,
        // foregroundColor: Colors.white,
        // showCameraButton: true, // Padrão é true se onTakePicture for fornecido
      ),
    );
  }
}

/// Estrutura do objeto Recognition (como tipicamente usado nos exemplos TFLite)
/// Você pode precisar ajustar baseado na sua classe interna 'Recognition' exata.
/*
class Recognition {
  final int id;        // Geralmente um índice
  final String label;  // Nome do objeto detectado (rótulo)
  final double score;  // Score de confiança (0.0 a 1.0)
  final Rect location; // Caixa delimitadora (coordenadas relativas)

  Recognition(this.id, this.label, this.score, this.location);
}
*/
Use code with caution.
Dart
Parâmetros do DetectorWidget
onResult (obrigatório, Function(List<Recognition>)): Callback invocado frequentemente com a lista de objetos detectados. Cada objeto Recognition fornece detalhes como rótulo, score de confiança e localização.
onTakePicture (opcional, Function(XFile)?): Callback invocado quando o usuário toca no botão de captura. Retorna um objeto XFile (do pacote camera). Se for null, o botão da câmera não será mostrado por padrão.
icon (opcional, IconData): Ícone usado para o botão de captura. Padrão é Icons.camera.
backgroundColor (opcional, Color): Cor de fundo do círculo do botão de captura. Padrão é Colors.white.
foregroundColor (opcional, Color): Cor do ícone no botão de captura. Padrão é Colors.black.
iconSize (opcional, double): Tamanho do ícone do botão de captura. Padrão é 100.0.
showCameraButton (opcional, bool): Controla explicitamente a visibilidade do botão da câmera. Padrão é true se onTakePicture for fornecido, caso contrário false. Se definido como true mas onTakePicture for null, o botão aparecerá mas não fará nada ao ser tocado.
Modelo Utilizado
Este pacote usa um modelo pré-treinado SSD MobileNet v1 (ssd_mobilenet.tflite) e os rótulos correspondentes (labelmap.txt) empacotados como assets para realizar a detecção de objetos. Estes assets estão incluídos dentro do pacote.
IMPORTANTE: O modelo e os rótulos incluídos são tipicamente derivados da TensorFlow Object Detection API e frequentemente distribuídos sob a Licença Apache 2.0. Por favor, verifique os termos de licença específicos aplicáveis aos arquivos do modelo que você empacotou se eles diferirem dos exemplos padrão do TensorFlow. Garanta a conformidade ao usar ou distribuir este pacote.
Agradecimentos
A lógica central de detecção e a estrutura do widget são inspiradas e adaptam conceitos do exemplo oficial do TensorFlow Lite Flutter:
https://github.com/tensorflow/flutter-tflite/blob/main/example/live_object_detection_ssd_mobilenet
Informações Adicionais
Encontre o código fonte no GitHub. <!-- ATUALIZE O LINK -->
Reporte problemas no issue tracker. <!-- ATUALIZE O LINK -->
Contribuições são bem-vindas!
Licença
Este pacote é licenciado sob a Licença MIT.