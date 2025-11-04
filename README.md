# UltraCMA - Enterprise Cash Management Account System

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.1-brightgreen.svg)](https://github.com/mjmilne1/UltraCMA/releases)

## 🏦 Overview

**UltraCMA** is an enterprise-grade Cash Management Account system integrated with [UltraLedger](https://github.com/mjmilne1/UltraLedger) - a next-generation financial ledger infrastructure with bitemporal data model and event sourcing.

## ✨ Recent Updates (v2.1)

- ✅ Modular architecture (.psm1 modules)
- ✅ Improved UltraLedger integration
- ✅ Simplified API
- ✅ Better error handling
- ✅ Working demo with balanced ledger

## 🚀 Quick Start
```powershell
# Clone the repository
git clone https://github.com/mjmilne1/UltraCMA.git
cd UltraCMA

# Run setup
.\Setup.ps1

# Or directly
cd src\core
Import-Module .\UltraCMA.Core.psm1
Start-CMADemo
```

## 📊 Demo Results

Latest successful demo:
- Customers: 2
- Payments: 2
- Volume: 1,500 AUD
- Balance Sheet: ✅ Balanced

## 🏗️ Architecture

- **Pattern**: Event-Sourced CQRS
- **Model**: Bitemporal (Valid Time + Record Time)
- **Ledger**: Double-entry bookkeeping
- **Storage**: In-memory (demo) / PostgreSQL (production)

## 📁 Repository Structure
```
UltraCMA/
├── src/
│   └── core/
│       ├── UltraCMA.Core.psm1      # Main module
│       ├── UltraCMA-Enterprise.ps1  # Legacy script
│       └── Start-Enterprise.ps1     # Launcher
├── .github/
├── README.md
├── LICENSE
└── Setup.ps1
```

## 🔗 Related Projects

- [UltraLedger](https://github.com/mjmilne1/UltraLedger) - Bitemporal ledger infrastructure (Java)
- [UltraPlatform](https://github.com/mjmilne1/UltraPlatform) - Unified platform

## 📝 License

MIT

## 👨‍💻 Author

Michael Milne (mjmilne1)
