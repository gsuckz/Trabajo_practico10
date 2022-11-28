# Práctico 10 - Electrónica II 2022 para ingeniería electrónica - Máquinas de estado finito

El objetivo de este práctico es desarrollar un receptor de control remoto infrarrojo con código NEC, incluyendo el desarrollo completo del proyecto de ghdl con testbench, Makefile para ejecutar banco de prueba y visualización con gtkwave.

Dado la complejidad adicional se dará guía en clase de práctica y clases de consulta.

## Instrucciones para preparación y entrega del práctico

Para completar el práctico deberás generar un repositorio git que incluya, además de este archivo, un banco de pruebas, un Makefile y una implementación. El código vhdl del banco de prueba debe estar en el archivo `testbench.vhd`. El código de la implementación (entidad y arquitectura) estará en el archivo `design.vhd`. Deberás preparar un archivo Makefile (Makefile) con los siguientes objetivos:

- `mingw32-make receptor_ir`     : Ejecuta el banco de pruebas presentando los resultados reportados.
- `mingw32-make wav-receptor_ir` : Ejecuta el banco de pruebas guardando las formas de onda y luego ejecuta gtkwave para presentar el resultado.
- `mingw32-make`                 : Hace lo mismo que `mingw32-make receptor_ir`

Durante la elaboración de tu práctico utilizarás el sistema de control de versiones git y alojarás el resultado en github. Para ello debes crear una cuenta en github.com si no tienes una aún, crear un repositorio propio usando este como plantilla y clonar el nuevo repositorio en tu máquina. Para trabajar el repositorio en tu máquina será el repositorio de trabajo, el repositorio en la nube se denomina repositorio remoto. Guardarás tu progreso en tu repositorio de trabajo y publicaras los resultados (usando el comando push) en el repositorio remoto. Una vez consideres que tu práctico está completo te asegurrás que tu repositorio remoto sea público en github y enviarás como respuesta a la tarea correspondiente un enlace a dicho repositorio. Si debes realizar correcciones bastará con actualizar el repositorio remoto (pues el enlace siempre contendrá la versión más reciente y todas las anteriores que hayas guardado).

Este práctico puede hacerse en grupos de hasta tres personas.

## Receptor de control remoto infrarrojo

Es una máquina de estado finito que permite recibir comandos de un control remoto infrarrojo que implemente el [protocolo NEC](https://techdocs.altium.com/display/FPGA1/NEC+Infrared+Transmission+Protocol).

### El protocolo NEC

El transmisor genera una señal infrarroja consistente en pulsos infrarrojos modulados encendido-apagado (On Off Keying - OOK) con una frecuencia de 38 kHz. Los datos transmitidos se codifican usando **la duración del intervalo entre pulsos**. El módulo receptor tiene su salida normalmente en '1' y la salida toma el valor '0' cuando detecta la presencia de señal infrarroja de 38 kHz. Cada transmisión está formado por un inicio de transmisión, 8 bits de dirección y 8 bits de comando. Si el botón se mantiene presionado el control transmite un código de repetición en lugar de repetir la transmisión completa.

El inicio de transmisión consiste en un pulso de `9 ms` seguido de un espacio de `4,5 ms`. Luego del inicio de transmisión siguen 8 bits de la dirección, de LSb a MSb. Continúa con el complemento lógico de la dirección (siempre de LSb a MSb), los 8 bits del comando, el complemento lógico del comando y un pulso de fin. Un bit '0' consiste en un pulso de duración `Tp=562,5 μs` seguido de un espacio de la misma duración. Un bit '1' consiste en un pulso de duración `Tp` seguido de un espacio del triple de su duración (`3Tp=1,6875 ms`). El pulso de fin de transmisión es un pulso de duración `Tp`.

```
Ejemplo: (dir "01100101", cmd "00101001")
T = 562,5 μs 

╔══════════════════════════════════ Señal IR ════════════════════════════════════╗
║                                                                                 ║
║ ◄─────────────────────── Inicio de transmisión ────────────────────────►        ║
║ ████████████████████████████████████████████████                        ███   █ ║
║ ◄──────────────── 9 ms = 16 T ─────────────────►◄──── 4,5 ms = 8 T ────►        ║
║                                                                                 ║
║ ◄───────────────────────────── Dirección ──────────────────────────────►        ║
║ ███   ███         ███         ███   ███   ███         ███   ███         ███   █ ║
║ ◄ 2T ►◄─── 4T ───►◄─── 4T ───►◄ 2T ►◄ 2T ►◄─── 4T ───►◄ 2T ►◄─── 4T ───►        ║
║                                                                                 ║
║ ◄────────────────────── Complemento de Dirección ──────────────────────►        ║
║ ███         ███   ███   ███         ███         ███   ███         ███   ███   █ ║
║ ◄─── 4T ───►◄ 2T ►◄ 2T ►◄─── 4T ───►◄─── 4T ───►◄ 2T ►◄─── 4T ───►◄ 2T ►        ║
║                                                                                 ║
║ ◄─────────────────────────── Comando ────────────────────────────►              ║
║ ███   ███   ███         ███   ███         ███   ███   ███         ███         █ ║
║ ◄ 2T ►◄ 2T ►◄─── 4T ───►◄ 2T ►◄─── 4T ───►◄ 2T ►◄ 2T ►◄─── 4T ───►              ║
║                                                                                 ║
║                                                                                 ║
║                                                                                 ║
║ ◄────────────────────────── Complemento de Comando ──────────────────────────►  ║
║ ███         ███         ███   ███         ███   ███         ███         ███   █ ║
║ ◄─── 4T ───►◄─── 4T ───►◄ 2T ►◄─── 4T ───►◄ 2T ►◄─── 4T ───►◄─── 4T ───►◄ 2T ►  ║
║                                                                                 ║
║ ◄───── Fin ──────►                                                              ║
║ ███               ....                                                          ║
║ ◄─ Mayor que 5T ─►                                                              ║
║                                                                                 ║
╠══════════════════════════════ Salida receptor IR ═══════════════════════════════╣
║                                                                                 ║
║ ├─────────────────────── Inicio de transmisión ─────────────────────────┤       ║
║ ┐                                               ┌───────────────────────┐  ┌──┐ ║
║ │                                               │                       │  │  │ ║
║ └───────────────────────────────────────────────┘                       └──┘  └ ║
║ ├──────────────── 9 ms = 16 T ──────────────────┼──── 4,5 ms = 8 T ─────┤       ║
║                                                                                 ║
║ ├───────────────────────────── Dirección ───────────────────────────────┤       ║
║ ┐  ┌──┐  ┌────────┐  ┌────────┐  ┌──┐  ┌──┐  ┌────────┐  ┌──┐  ┌────────┐  ┌──┐ ║
║ │  │  │  │        │  │        │  │  │  │  │  │        │  │  │  │        │  │  │ ║
║ └──┘  └──┘        └──┘        └──┘  └──┘  └──┘        └──┘  └──┘        └──┘  └ ║
║ ├ 2T ─┼─── 4T ────┼─── 4T ────┼ 2T ─┼ 2T ─┼─── 4T ────┼ 2T ─┼─── 4T ────┤       ║
║                                                                                 ║
║ ├────────────────────── Complemento de Dirección ───────────────────────┤       ║
║ ┐  ┌────────┐  ┌──┐  ┌──┐  ┌────────┐  ┌────────┐  ┌──┐  ┌────────┐  ┌──┐  ┌──┐ ║
║ │  │        │  │  │  │  │  │        │  │        │  │  │  │        │  │  │  │  │ ║
║ └──┘        └──┘  └──┘  └──┘        └──┘        └──┘  └──┘        └──┘  └──┘  └ ║
║ ├─── 4T ────┼ 2T ─┼ 2T ─┼─── 4T ────┼─── 4T ────┼ 2T ─┼─── 4T ────┼ 2T ─┤       ║
║                                                                                 ║
║ ├─────────────────────────── Comando ─────────────────────────────┤             ║
║ ┐  ┌──┐  ┌──┐  ┌────────┐  ┌──┐  ┌────────┐  ┌──┐  ┌──┐  ┌────────┐  ┌────────┐ ║
║ │  │  │  │  │  │        │  │  │  │        │  │  │  │  │  │        │  │        │ ║
║ └──┘  └──┘  └──┘        └──┘  └──┘        └──┘  └──┘  └──┘        └──┘        └ ║
║ ├ 2T ─┼ 2T ─┼─── 4T ────┼ 2T ─┼─── 4T ────┼ 2T ─┼ 2T ─┼─── 4T ────┤             ║
║                                                                                 ║
║                                                                                 ║
║ ├────────────────────────── Complemento de Comando ───────────────────────────┤ ║
║ ┐  ┌────────┐  ┌────────┐  ┌──┐  ┌────────┐  ┌──┐  ┌────────┐  ┌────────┐  ┌──┐ ║
║ │  │        │  │        │  │  │  │        │  │  │  │        │  │        │  │  │ ║
║ └──┘        └──┘        └──┘  └──┘        └──┘  └──┘        └──┘        └──┘  └ ║
║ ├─── 4T ────┼─── 4T ────┼ 2T ─┼─── 4T ────┼ 2T ─┼─── 4T ────┼─── 4T ────┼ 2T ─┤ ║
║                                                                                 ║
║ ├───── Fin ───────┤                                                             ║
║ ┐  ┌──────────────....                                                          ║
║ │  │              ....                                                          ║
║ └──┘              ....                                                          ║
║ ├─ Mayor que 5T ──┤                                                             ║ 
║                                                                                 ║
╚════════════════════════════════════════════════════════════════════════════════╝

```

El código de repetición consiste en un pulso de `9 ms` seguido de un espacio de `2,25 ms` y un pulso final de `562,5 μs`. Se transmite periódicamente luego de un código de comando si la correspondiente tecla permanece presionada.

```
Ejemplo: (Repetición)
T = 562,5 μs 

╔═════════════════════════════════════ Señal IR ══════════════════════════════════════╗
║                                                                                     ║
║ ◄─────────────────────────── Código de repetición ───────────────────────────►      ║
║ ████████████████████████████████████████████████            ███               ....  ║
║ ◄──────────────── 9 ms = 16 T ─────────────────►◄ 2,25 ms ─►◄─ Mayor que 5T ─►      ║
║                                                                                     ║
╠════════════════════════════════ Salida receptor IR ═════════════════════════════════╣
║                                                                                     ║
║ ├─────────────────────────── Código de repetición ────────────────────────────┤     ║
║ ┐                                               ┌───────────┐  ┌──────────────....  ║
║ │                                               │           │  │              ....  ║
║ └───────────────────────────────────────────────┘           └──┘              ....  ║
║ ├──────────────── 9 ms = 16 T ──────────────────┼ 2,25 ms ──┼─ Mayor que 5T ──┤     ║
║                                                                                     ║
╚═════════════════════════════════════════════════════════════════════════════════════╝
```

### Especificación del receptor

El receptor de control remoto tendrá cuatro entradas y tres salidas.
Puertos:
- rst        : entrada `std_logic` de reset.
- infrarrojo : entrada `std_logic` conectada al receptor infrarrojo (vale '0' cuando detecta señal infrarroja).
- hab        : entrada `std_logic` de habilitación de reloj.
- clk        : entrada `std_loigc` de reloj, activo en flanco ascendente. 
- valido     : salida  `std_logic` toma el valor '1' al recibir transmisión válida, se mantiene hasta el inicio de otra posible transmisión.
- dir        : salida `std_logic_vector (7 downto 0)` con los 8 bits del campo "dirección" de la última transmisión válida recibida (`x"00"` luego del reset).
- cmd        : salida `std_logic_vector (7 downto 0)` con los 8 bits del campo "comando" de la última transmisión válida recibida (`x"00"` luego del reset).


#### Entradas de reloj y habilitación

El flanco activo del reloj debe ser el flanco ascendente. La entrada de habilitación de reloj opera de forma *sincrónica*, los flancos de reloj cuando la habilitación es '0' deben preservar siempre el estado anterior en todos los elementos de memoria. Los flancos ascendentes con habilitación en '1' son los que se deben tener en cuenta como válidos para el funcionamiento de la máquina de estado.

Los flancos de reloj válidos (con habilitación '1') tendrán un periodo de *exactamente* **187,5 μs**, esto es la tercera parte del tiempo más corto del protocolo NEC.

```
   ┌──────────────────────────────┐
   │                              │
───┤rst                     valido├───
   │                              │
───┤infrarrojo         dir(7 .. 0)╞═══
   │                              │
───┤hab                           │
   │                              │
───┤> clk              cmd(7 .. 0)╞═══
   └──────────────────────────────┘


╔═══════════════════════════════════════════ Diagrama de tiempo. Ejemplo para dir = 0xFD, cmd = 0x5A ════════════════════════════════════════════╗
║            ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─── ║
║ dir        ┤00                                                                                                                            │FD  ║
║            └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─── ║
║            ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─── ║
║ cmd        ┤00                                                                                                                            │5A  ║
║            └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─── ║
║                                                                                                                                           ┌─── ║
║ valido     ┐                                                                                                                              │    ║
║            └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘    ║
║                                                                                                                                                ║
║            ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ║
║ hab        ┘                                                                                                                                   ║
║                                                                                                                                                ║
║                                                                                                                                                ║
║ clk        ███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████ ║
║                                                                                                                                          3     ║
║ (periodos clk)  ├───── 48 ──────┼─ 16 ──┼12 ┼12 ┼12 ┼12 ┼12 ┼12 ┼6┼12 ┼6┼6┼6┼6┼6┼6┼12 ┼6┼6┼12 ┼6┼12 ┼12 ┼6┼12 ┼6┼12 ┼6┼12 ┼6┼6┼12 ┼6┼12 ┼┤     ║
║                                                                                                                                                ║
║            ─────┐               ┌───────┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌┐┌──┐┌┐┌┐┌┐┌┐┌┐┌┐┌──┐┌┐┌┐┌──┐┌┐┌──┐┌──┐┌┐┌──┐┌┐┌──┐┌┐┌──┐┌┐┌┐┌──┐┌┐┌──┐┌──── ║
║ infrarrojo      │               │       ││  ││  ││  ││  ││  ││  ││││  ││││││││││││││  ││││││  ││││  ││  ││││  ││││  ││││  ││││││  ││││  ││     ║
║                 └───────────────┘       └┘  └┘  └┘  └┘  └┘  └┘  └┘└┘  └┘└┘└┘└┘└┘└┘└┘  └┘└┘└┘  └┘└┘  └┘  └┘└┘  └┘└┘  └┘└┘  └┘└┘└┘  └┘└┘  └┘     ║
║                                                                                                                                                ║
║            ┐                                                                                                                                   ║
║ Rst        │                                                                                                                                   ║
║            └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

```
