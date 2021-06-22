pragma solidity 0.7.5;
pragma abicoder v2;

import './Owners.sol';

contract MultisigWallet is Owners{
    
    struct Transaction{
        address transmitter;
        address payable receiver;
        uint amount;
        uint confirmationCount;
        uint txnId;
    }
    
    Transaction[] transactions;
    
    // mapping of an address to its balance.
    mapping(address => uint)balance; 
    //mapping of a transaction id to an array of owner addresses those who've approved.
    mapping(uint => address[])checkApprovals; 
    //mapping of a transaction id to a transaction itself.
    mapping(uint => Transaction)transactionLog; 
    
    event AmountDeposited(address indexed depositor, uint amount);
    event TransactionCreated(address sender, address receiver, uint amount,uint txnId);
    event ViewTransaction(address sender, address receiver, uint amount,uint txnId, uint approvalCount, uint approvalsNeeded);
    
    //takes input as an array of owners and the number of approvals needed for a transfer request
    constructor(address[] memory _allOwners , uint _approvals) {
        //approvals must be less than number of owners. As an owner can't approve his own request
        require(_approvals < _allOwners.length && _approvals > 0 , 'Invalid number of approvals');
        allOwners = _allOwners;
        numberOfApprovals = _approvals;
        for(uint i = 0 ; i < _allOwners.length ; i++){
            isOwner[allOwners[i]] = true;
        }
    
    }
    
    // anybody can deposit funds in the wallet
    function deposit()public payable returns(uint){
        balance[msg.sender] += msg.value;
        emit AmountDeposited(msg.sender , msg.value);
        return balance[msg.sender];
    }
    
    // a function for creating a transfer request, takes input as a recipient address and an amount to tranfer
    function createTxn(address payable _recipient,uint _amount) public onlyOwners{
          require(balance[msg.sender] >= _amount , 'The amount is beyond deposited.');
          require(msg.sender != _recipient,"You can't transfer to yourself");
          Transaction memory txn = Transaction(msg.sender,_recipient,_amount,0,transactions.length);  
          transactionLog[transactions.length] = txn;
          emit TransactionCreated(msg.sender,_recipient, _amount,transactions.length);
          transactions.push(txn);
    }
    
     /* 
       a function for approving tranfer request.
       a creator of transfer request can not approve his own request
       an owner can not approve a request more than once.
     */
    function approveTxn(uint _txnId) public onlyOwners {
        require(transactionLog[_txnId].transmitter != msg.sender,"You can't approve your own transaction");
        require(checkApprovals[_txnId].length < allOwners.length,"Approvals can't be more than #owners");
        for(uint i = 0 ; i < checkApprovals[_txnId].length ; i++){
            require(msg.sender != checkApprovals[_txnId][i],"You've already approved the transaction");
        }
        checkApprovals[_txnId].push(msg.sender);
        transactionLog[_txnId].confirmationCount += 1;
    }
    
    //once a request has required number of approvals, it can be executed by the request creator.
    function runTxn(uint _txnId) public onlyOwners{
        Transaction memory txn = transactionLog[_txnId];
        require(txn.transmitter == msg.sender,'Please create a transaction first.');
        require(txn.confirmationCount < allOwners.length,"Approvals can't be more than owners");
        require(txn.confirmationCount >= numberOfApprovals,'Please get your transaction approved');
        uint oldBalance = balance[msg.sender];
        balance[msg.sender] -= txn.amount;
        txn.receiver.transfer(txn.amount);
        assert(balance[msg.sender] == oldBalance - txn.amount);
    }
   
   // an owner can withdraw his own funds.
   function withdrawMyFunds(uint amount) public onlyOwners returns(uint){
        require(balance[msg.sender] >= amount,'Withdrawal is more than a deposit');
        uint oldBlance = balance[msg.sender];
        balance[msg.sender] -= amount;
        msg.sender.transfer(amount);
        assert(balance[msg.sender] == oldBlance - amount);
        return balance[msg.sender];
   }
   
   //an owner can check his balance
    function myBalance() public view onlyOwners returns(uint){
        return balance[msg.sender];
    }
    
    //anybody can check the wallet Balance
    function walletBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    //anybody can view transaction
    function viewTxn(uint _txnId) public returns(Transaction memory){
        Transaction memory txn = transactionLog[_txnId];
        emit ViewTransaction(txn.transmitter,txn.receiver,txn.amount,_txnId,txn.confirmationCount,numberOfApprovals);
        return transactionLog[_txnId];
    }
}
