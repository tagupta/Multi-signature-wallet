pragma solidity 0.7.5;

contract Owners{
    address [] allOwners;
    uint numberOfApprovals;
    mapping (address => bool) isOwner;
    
    modifier onlyOwners {
        require(isOwner[msg.sender],'Accessible by owners only');
        _;
    }
    
    function getOwners() public view onlyOwners returns(address[]memory){
        return allOwners;
    }
    
}
