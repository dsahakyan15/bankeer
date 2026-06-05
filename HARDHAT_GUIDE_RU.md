# 🛠️ Шпаргалка по Hardhat 3

## 🏗️ Сборка и компиляция
*   `npx hardhat build` — скомпилировать контракты и сгенерировать типы (TypeChain).
*   `npx hardhat clean` — очистить кэш и папку с артефактами (`artifacts`, `cache`).
*   `npx hardhat compile` — (устаревший аналог `build`) просто компиляция контрактов.

## 🧪 Тестирование
Hardhat 3 разделяет тесты на два уровня: **Solidity** (быстрые юнит-тесты) и **TypeScript** (интеграционные тесты).

*   `npx hardhat test` — запустить **все** тесты.
*   `npx hardhat test solidity` — запустить только Solidity-тесты (файлы `.t.sol`).
*   `npx hardhat test mocha` — запустить только TypeScript-тесты (файлы `.ts` в папке `test/`).
*   `npx hardhat test --coverage` — проверить покрытие кода тестами (Solidity coverage).
*   `npx hardhat test <путь_к_файлу>` — запустить конкретный тестовый файл.

## 🚀 Развертывание (Ignition)
Hardhat 3 использует систему **Ignition** для управления деплоем.

*   `npx hardhat ignition deploy ./ignition/modules/Counter.ts` — развернуть модуль на локальной сети.
*   `npx hardhat ignition deploy ./ignition/modules/Counter.ts --network sepolia` — развернуть в сети Sepolia.
*   `npx hardhat ignition deploy ./ignition/modules/Counter.ts --network <network_name> --verify` — развернуть и автоматически верифицировать контракты.

## 🌐 Сети и узлы
*   `npx hardhat node` — запустить локальный Ethereum-узел (Hardhat Network).
*   `npx hardhat run <путь_к_скрипту> --network <имя_сети>` — запустить произвольный скрипт в конкретной сети.

## 🔧 Проверка типов (TypeScript)
Важно запускать после сборки, чтобы убедиться в правильности вызовов контрактов:
*   `npx hardhat build && npx tsc --noEmit`

## ❓ Справка и отладка
*   `npx hardhat help` — список всех доступных команд.
*   `npx hardhat help <команда>` — подробная справка по конкретной команде.
*   `npx hardhat flatten <путь_к_контракту>` — объединить контракт и все его зависимости в один файл.

---

### Примеры для текущего проекта:
*   **Деплой Counter:** `npx hardhat ignition deploy ./ignition/modules/Counter.ts`
*   **Запуск скрипта на OP:** `npx hardhat run ./scripts/send-op-tx.ts --network hardhatOp`
*   **Только Solidity тесты:** `npx hardhat test solidity`
