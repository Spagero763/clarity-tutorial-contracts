# Clarity Tutorial Contracts

A comprehensive collection of Clarity smart contracts for the Stacks blockchain covering DeFi, Gaming, NFTs, and token standards.

## Quick Start

\\\ash
# Navigate to any project
cd counter

# Check contract syntax
clarinet check

# Run tests
npm test

# Interactive console
clarinet console
\\\

## Projects Overview

### Basic Contracts
| Project | Description | Key Features |
|---------|-------------|--------------|
| **counter** | Simple counter | Increment, decrement, reset, overflow protection |
| **escrow** | Multi-party escrow | State management, refunds, multiple escrows |

### DeFi Contracts
| Project | Description | Key Features |
|---------|-------------|--------------|
| **Defi-staking** | Token staking | Reward calculation, claim mechanism, APY |
| **Defi-vault** | Secure storage | Time-delayed withdrawals, cancellation |
| **Defi-treasury** | Treasury management | Multi-sig support, spending limits |
| **Defi-yield** | Yield farming | LP tokens, reward distribution |

### Gaming Contracts
| Project | Description | Key Features |
|---------|-------------|--------------|
| **Gaming-leaderboard** | On-chain rankings | Multi-game, top 10 tracking |
| **Game-rewards** | Achievement system | Tiered rewards, authorized granters |
| **Gaming-pass** | Game subscriptions | Time-based access, tiers |
| **Gaming-Nft** | In-game items | Attributes, upgrades |

### Token Standards
| Project | Description | Key Features |
|---------|-------------|--------------|
| **fungible-token** | SIP-010 token | Allowances, burn, mint |
| **NFT** | SIP-009 NFT | Marketplace, royalties, metadata |

## Project Structure

Each project follows the standard Clarinet layout:

\\\
project/
 Clarinet.toml       # Project configuration
 contracts/          # Clarity smart contracts
 deployments/        # Deployment plans
 settings/           # Network configs
 tests/              # Vitest tests
\\\

## Common Commands

| Command | Description |
|---------|-------------|
| \clarinet check\ | Validate contract syntax |
| \clarinet test\ | Run Clarinet tests |
| \
pm test\ | Run Vitest tests |
| \clarinet console\ | Interactive REPL |
| \clarinet deploy\ | Deploy to network |

## Error Codes

Most contracts use standardized error codes:
- \u100\ - Not owner / unauthorized
- \u101\ - Invalid input
- \u102\ - Insufficient balance/funds
- \u103\ - Item not found
- \u104\ - Already exists
- \u105\ - Invalid state

## Security

These contracts are for educational purposes. Before mainnet deployment:
1. Audit all contracts thoroughly
2. Test extensively on testnet
3. Review access control patterns
4. Consider reentrancy and overflow attacks

## Resources

- [Clarity Documentation](https://docs.stacks.co/clarity)
- [Clarinet Guide](https://docs.hiro.so/clarinet)
- [SIP Standards](https://github.com/stacksgov/sips)

## License

MIT
