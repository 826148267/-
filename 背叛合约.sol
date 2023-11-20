pragma solidity ^0.4.0;
import "./prisoners.sol";
contract betrayal{

    address public client=0xEdDF494b84054aBFfDD4605b103eEAcDb1376bAa;
    address public audit=0x2b67CD470c47DF2F31610869807679f8Ca03A3a8;
    address public server=0xfdC6B9cB94549d604496dF69a23EE0C233361Ca7;

    mapping (address => bool ) public hasJoin;



    uint public f=1 ether;
    uint public db=5 ether;

    uint public H=5;
    
    prisoners P;


    enum StateB {INIT, Create, Prepare, Compute,Done, Compare, Error, Aborted,SendError}

    
    StateB public stateB = StateB.INIT;

    function() payable{

    }
    constructor(address pri) public{
        P = prisoners(pri);
    }

    function Create () public payable returns(bool){
        assert(stateB==StateB.INIT);
        assert(msg.sender==audit);
        assert(msg.value >= f);
        hasJoin[msg.sender]=true;
        stateB=StateB.Create;
        return true;
    }

    function Arouse() public payable returns(bool){
        uint T =now;
        assert(stateB==StateB.Create);
        assert(msg.value==db);
        assert(!hasJoin[msg.sender]);
        assert(msg.sender == client);

        hasJoin[msg.sender]=true;

        if (hasJoin[audit]==true && hasJoin[client]==true){
            stateB=StateB.Compute;
        }
        return true;
    }

    function Conduct() public payable returns (bool){
        uint T =now;
        assert(msg.sender==audit || msg.sender == client);
        assert(stateB==StateB.Compute);

        if(P.results(server)==H){
            address(uint160(audit)).transfer(db+f);
            stateB=StateB.Done;
        }
        else{
            address(uint160(client)).transfer(db+f);
            stateB=StateB.Done;
        }
       
        return true;
    }
    
}