# AES-128 ARM64 Assembly Encryptor

<p align="center">
  <img src="https://img.shields.io/badge/Architecture-ARM64-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Encryption-AES--128-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-Assembly-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Linux-lightgrey?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Stable-success?style=for-the-badge" />
</p>

---

## Language / Idioma

- [Versión en Español](#-versión-en-español)
- [English Version](#-english-version)

---

# Versión en Español

## Descripción

Proyecto que implementa el algoritmo **AES-128 (Advanced Encryption Standard)** completamente en **lenguaje ensamblador ARM64**, permitiendo el cifrado de cadenas ingresadas desde la consola.

El programa recibe una cadena de texto, la cifra utilizando una clave de 128 bits y devuelve el resultado en formato hexadecimal.

---

## Características

- Implementación manual de AES-128
- Entrada de texto desde consola
- Clave de 128 bits
- Compatible con arquitectura ARM64 (AArch64)
- Sin dependencias externas
- Compilable con `as` y `ld` o `gcc`

---

## Requisitos

- Sistema Linux ARM64
- GNU Assembler (`as`)
- GNU Linker (`ld`) o `gcc`
- QEMU

---

### Requisitos adicionales

Instalar toolchain y QEMU:

```bash
    sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user
```

---

## Compilación Cruzada y Ejecución con QEMU

Este proyecto utiliza herramientas de **cross-compilation para ARM64 (AArch64)** y ejecuta el binario mediante QEMU. Para la ejecución se utiliza el script incluido que compila y ejecuta el programa, para ello, desde una terminal de linux con QEMU, se ejecuta el comando

```bash
chmod +x build.sh
./build.sh
```

---

# AES-128 ARM64 Assembly Encryptor

---

## Description

This project implements the **AES-128 (Advanced Encryption Standard)** algorithm entirely in **ARM64 (AArch64) assembly language**, allowing encryption of strings entered via the console.

The program receives plaintext input, encrypts it using a 128-bit key, and outputs the ciphertext in hexadecimal format.

---

## Features

* Manual AES-128 implementation
* Console-based input
* 128-bit encryption key
* Compatible with ARM64 (AArch64)
* No external dependencies
* Cross-compilation support
* Linux compatible

---

## Requirements

* Linux environment (x86_64 or ARM64)
* ARM64 cross toolchain:
  * `aarch64-linux-gnu-as`
  * `aarch64-linux-gnu-ld`
* QEMU user-mode emulator

Install dependencies (Debian/Ubuntu):

```bash
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user
```

---

## Cross Compilation and Execution with QEMU

The project uses ARM64 cross-compilation tools and executes the generated binary using QEMU.

---

### Run the Script

```bash
chmod +x build.sh
./build.sh
```

---

## Example Execution

```bash
Enter text: HelloWorld
Encrypted text (hex):
3ad77bb40d7a3660a89ecaf32466ef97
```

---

## Internal Implementation

The AES-128 implementation includes:

* SubBytes
* ShiftRows
* MixColumns
* AddRoundKey
* Key Expansion (10 rounds for AES-128)

All written entirely in ARM64 assembly using general-purpose registers and native logical operations.

---
