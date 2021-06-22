# Multi-signature-wallet
A contract for Mutli-signature wallet. 
This contract is integrated using remix IDE.

I have partitioned the code into two files for better structuring using inheritance. 
```Owners.sol``` is associated with owners only. The main functionality I’ve implemented in ```Wallet.sol```.

I’ve segregated the action of the transfer function into 3 other functions -

```createTxn()``` - For creating a transfer request.

```approveTxn()``` - Using this function, other owners can approve the transaction.

```runTxn()``` - The creator of the transfer request can run the transaction after getting the required number of approvals.

## Disclaimer
This code is not audited. Please make sure to audit your code before using it for production.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


