# Clarity Tutorial Contracts

A comprehensive collection of Clarity smart contracts for the Stacks blockchain. This repository contains various tutorial projects covering DeFi, Gaming, NFTs, and more.

## 📁 Project Structure

This workspace contains multiple independent Clarity projects, each demonstrating different smart contract patterns:

### 🔢 Basic Contracts
| Project | Description |
|---------|-------------|
| `counter/` | Simple counter contract - great starting point for beginners |
| `escrow/` | Escrow service contract for secure transactions |

### 💰 DeFi Contracts
| Project | Description |
|---------|-------------|
| `Defi-emergency/` | Emergency withdrawal and circuit breaker patterns |
| `Defi-fee/` | Fee collection and distribution mechanisms |
| `Defi-reward/` | Reward distribution systems |
| `Defi-staking/` | Token staking functionality |
| `Defi-time-locked/` | Time-locked token contracts |
| `Defi-treasury/` | Treasury management contracts |
| `Defi-vault/` | Vault contracts for secure asset storage |
| `Defi-yield/` | Yield farming mechanisms |

### 🎮 Gaming Contracts
| Project | Description |
|---------|-------------|
| `Game-rewards/` | In-game reward systems |
| `Gaming-leaderboard/` | On-chain leaderboard functionality |
| `Gaming-Nft/` | Gaming NFT integration |
| `Gaming-pass/` | Game pass/subscription contracts |
| `Gaming-registry/` | Player and game registry |

### 🖼️ Token Contracts
| Project | Description |
|---------|-------------|
| `fungible-token/` | SIP-010 fungible token implementation |
| `NFT/` | SIP-009 non-fungible token implementation |

## 🛠️ Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Node.js](https://nodejs.org/) (v16 or higher)
- npm or yarn

## 🚀 Getting Started

### 1. Install Clarinet

```bash
# Using Homebrew (macOS/Linux)
brew install clarinet

# Using Chocolatey (Windows)
choco install clarinet

# Or download from GitHub releases
# https://github.com/hirosystems/clarinet/releases
```

### 2. Navigate to a Project

```bash
cd counter
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Run Tests

```bash
# Using Clarinet
clarinet test

# Or using Vitest
npm test
```

### 5. Check Contracts

```bash
clarinet check
```

### 6. Open Console (Interactive REPL)

```bash
clarinet console
```

## 📖 Project Structure (Individual Projects)

Each project follows this structure:

```
project-name/
├── Clarinet.toml          # Clarinet configuration
├── package.json           # Node.js dependencies
├── tsconfig.json          # TypeScript configuration
├── vitest.config.js       # Vitest test configuration
├── contracts/             # Clarity smart contracts
│   └── contract-name.clar
├── deployments/           # Deployment plans
│   └── default.mainnet-plan.yaml
├── settings/              # Network settings
│   └── Devnet.toml
└── tests/                 # Test files
    └── contract-name.test.ts
```

## 📚 Resources

- [Clarity Language Documentation](https://docs.stacks.co/clarity)
- [Clarinet Documentation](https://docs.hiro.so/clarinet)
- [Stacks Documentation](https://docs.stacks.co/)
- [SIP-009 NFT Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-009/sip-009-nft-standard.md)
- [SIP-010 Fungible Token Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)

## 🧪 Testing

Each project uses Vitest for testing. Common test commands:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## 🔐 Security Considerations

These contracts are for educational purposes. Before deploying to mainnet:

1. Conduct thorough security audits
2. Test extensively on testnet
3. Review all access control mechanisms
4. Consider edge cases and potential attack vectors

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Happy coding with Clarity! 🎉
