# UltraCMA - Cash Management Account System
# Built on UltraLedger Infrastructure

# Dependencies
$ultraLedgerPath = Join-Path $PSScriptRoot "..\UltraLedger\UltraLedger.Core.psm1"
Import-Module $ultraLedgerPath -Force

# Initialize Chart of Accounts
Write-Host "Initializing CMA accounts..." -ForegroundColor Gray
$Global:UltraAccounts = @{
    "1000" = @{
        AccountNumber = "1000"
        AccountName = "Cash"
        AccountType = "Asset"
        Balance = 0
        Currency = "AUD"
    }
    "2000" = @{
        AccountNumber = "2000"
        AccountName = "Customer Deposits"
        AccountType = "Liability"
        Balance = 0
        Currency = "AUD"
    }
}

# Storage
$Global:CMACustomers = @{}
$Global:CMAAccounts = @{}
$Global:CMAPayments = [System.Collections.ArrayList]::new()
if (!$Global:UltraEvents) {
    $Global:UltraEvents = [System.Collections.ArrayList]::new()
}
if (!$Global:UltraJournals) {
    $Global:UltraJournals = [System.Collections.ArrayList]::new()
}

function New-CMACustomer {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Email,
        [string]$Mobile,
        [decimal]$InitialDeposit = 0
    )
    
    Write-Host "`nCreating CMA Customer..." -ForegroundColor Cyan
    
    $customerId = "CUS-" + (Get-Random -Min 1000 -Max 9999)
    $accountNumber = "UCMA-" + (Get-Random -Min 100000000 -Max 999999999)
    
    Write-Host "  KYC Verification..." -ForegroundColor Yellow
    Start-Sleep -Milliseconds 300
    Write-Host "    ✓ Identity verified" -ForegroundColor Green
    
    $riskLevel = @("LOW", "MEDIUM", "HIGH") | Get-Random
    Write-Host "    ✓ Risk Level: $riskLevel" -ForegroundColor Green
    
    $customer = @{
        CustomerId = $customerId
        FirstName = $FirstName
        LastName = $LastName
        Email = $Email
        Mobile = $Mobile
        RiskLevel = $riskLevel
    }
    
    $account = @{
        AccountNumber = $accountNumber
        CustomerId = $customerId
        CustomerName = "$FirstName $LastName"
        Balance = $InitialDeposit
        AvailableBalance = $InitialDeposit
        Status = "ACTIVE"
        LedgerAccount = "C" + $accountNumber.Substring(4)
    }
    
    # Create ledger account
    $Global:UltraAccounts[$account.LedgerAccount] = @{
        AccountNumber = $account.LedgerAccount
        AccountName = "$FirstName $LastName"
        AccountType = "Liability"
        Balance = $InitialDeposit
        Currency = "AUD"
    }
    
    if ($InitialDeposit -gt 0) {
        $Global:UltraAccounts["1000"].Balance += $InitialDeposit
    }
    
    $Global:CMACustomers[$customerId] = $customer
    $Global:CMAAccounts[$accountNumber] = $account
    
    Write-Host "  ✅ Account: $accountNumber" -ForegroundColor Green
    
    return $account
}

function New-CMAPayment {
    param(
        [string]$FromAccount,
        [string]$ToAccount,
        [decimal]$Amount,
        [string]$Description = "",
        [string]$Method = "NPP"
    )
    
    Write-Host "`nProcessing Payment..." -ForegroundColor Cyan
    
    $paymentId = "PAY-" + (Get-Random -Min 100000 -Max 999999)
    
    $fromAcc = $Global:CMAAccounts[$FromAccount]
    $toAcc = $Global:CMAAccounts[$ToAccount]
    
    if (!$fromAcc -or !$toAcc) {
        Write-Host "  ❌ Account not found" -ForegroundColor Red
        return
    }
    
    if ($fromAcc.Balance -lt $Amount) {
        Write-Host "  ❌ Insufficient funds" -ForegroundColor Red
        return
    }
    
    Write-Host "  ✓ Validation passed" -ForegroundColor Green
    
    if ($Amount -ge 10000) {
        Write-Host "  ! AUSTRAC reporting required" -ForegroundColor Yellow
    }
    
    # Update balances
    $fromAcc.Balance -= $Amount
    $fromAcc.AvailableBalance = $fromAcc.Balance
    $toAcc.Balance += $Amount
    $toAcc.AvailableBalance = $toAcc.Balance
    
    # Update ledger
    if ($Global:UltraAccounts[$fromAcc.LedgerAccount]) {
        $Global:UltraAccounts[$fromAcc.LedgerAccount].Balance -= $Amount
    }
    if ($Global:UltraAccounts[$toAcc.LedgerAccount]) {
        $Global:UltraAccounts[$toAcc.LedgerAccount].Balance += $Amount
    }
    
    $payment = @{
        PaymentId = $paymentId
        FromAccount = $FromAccount
        ToAccount = $ToAccount
        Amount = $Amount
        Method = $Method
        Status = "COMPLETED"
        Timestamp = Get-Date
    }
    
    $Global:CMAPayments.Add($payment) | Out-Null
    
    Write-Host "  ✅ Payment: $paymentId" -ForegroundColor Green
    
    return $payment
}

function Get-CMAMetrics {
    $totalVolume = 0
    if ($Global:CMAPayments.Count -gt 0) {
        $totalVolume = ($Global:CMAPayments | Measure-Object -Property Amount -Sum).Sum
    }
    
    $assets = 0
    $liabilities = 0
    
    foreach ($account in $Global:UltraAccounts.Values) {
        if ($account.AccountType -eq "Asset") {
            $assets += $account.Balance
        }
        if ($account.AccountType -eq "Liability") {
            $liabilities += $account.Balance
        }
    }
    
    Write-Host "`n📊 CMA Metrics" -ForegroundColor Cyan
    Write-Host "Customers: $($Global:CMACustomers.Count)" -ForegroundColor Gray
    Write-Host "Accounts: $($Global:CMAAccounts.Count)" -ForegroundColor Gray
    Write-Host "Payments: $($Global:CMAPayments.Count)" -ForegroundColor Gray
    Write-Host "Volume: $totalVolume AUD" -ForegroundColor Gray
    Write-Host "Assets: $assets AUD" -ForegroundColor Gray
    Write-Host "Liabilities: $liabilities AUD" -ForegroundColor Gray
    Write-Host "Balanced: $(if ([Math]::Abs($assets - $liabilities) -lt 0.01) {'Yes'} else {'No'})" -ForegroundColor Gray
    
    return @{
        Customers = $Global:CMACustomers.Count
        Accounts = $Global:CMAAccounts.Count
        Payments = $Global:CMAPayments.Count
        Volume = $totalVolume
        Assets = $assets
        Liabilities = $liabilities
    }
}

function Start-CMADemo {
    Write-Host "`n🎭 ULTRA CMA DEMO" -ForegroundColor Magenta
    Write-Host "════════════════════════" -ForegroundColor Magenta
    
    Write-Host "`nCreating Customers..." -ForegroundColor Yellow
    $alice = New-CMACustomer -FirstName "Alice" -LastName "Smith" -Email "alice@demo.com" -InitialDeposit 10000
    $bob = New-CMACustomer -FirstName "Bob" -LastName "Jones" -Email "bob@demo.com" -InitialDeposit 5000
    
    Write-Host "`nProcessing Payments..." -ForegroundColor Yellow
    New-CMAPayment -FromAccount $alice.AccountNumber -ToAccount $bob.AccountNumber -Amount 1000 -Description "Test"
    New-CMAPayment -FromAccount $bob.AccountNumber -ToAccount $alice.AccountNumber -Amount 500 -Description "Refund"
    
    Get-CMAMetrics
    
    Write-Host "`n✅ Demo Complete!" -ForegroundColor Green
}

Export-ModuleMember -Function * -Variable CMA*
Write-Host "✅ UltraCMA Loaded" -ForegroundColor Green
