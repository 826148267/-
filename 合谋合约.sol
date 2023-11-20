
pragma solidity ^0.4.0;
import "./prisoners.sol";
contract Colluders {

    address public Leader=0xfdC6B9cB94549d604496dF69a23EE0C233361Ca7;
    address public follower=0x2b67CD470c47DF2F31610869807679f8Ca03A3a8;

    mapping (address => uint ) public results;
    mapping (address => bool ) public hasJoin;



    uint public b=1 ether;
    uint public dc=4 ether;

    uint public H=5;
    
    prisoners P;


    enum StateC {INIT, Create, Prepare,Done, Compute, Compare, Error, Aborted,SendError}

    
    StateC public stateC = StateC.INIT;

    constructor(address pri) public{
        P = prisoners(pri);
    }

    function() payable{

    }

    function Create () public payable returns(bool){
        assert(stateC==StateC.INIT);
        assert(msg.sender==Leader);
        assert(msg.value >= b+dc);
        hasJoin[msg.sender]=true;
        stateC=StateC.Create;
        return true;
    }

    function Join () public payable returns(bool){
        uint T =now;
        assert(stateC==StateC.Create);
        assert(msg.value==dc);
        assert(!hasJoin[msg.sender]);
        assert(msg.sender == follower);

        hasJoin[msg.sender]=true;

        if (hasJoin[Leader]==true && hasJoin[follower]==true){
            stateC=StateC.Compute;
        }
        return true;
    }

    function Compare () public payable returns (bool){
        uint T =now;
        assert(msg.sender==Leader || msg.sender == follower);
        assert(stateC==StateC.Compute);

        if(P.results(Leader)==H&&P.results(follower)==H){
            address(uint160(Leader)).transfer(dc);
            address(uint160(follower)).transfer(dc+b);
            stateC=StateC.Done;
        }
        if(P.results(Leader)==H&&P.results(follower)!=H){
            address(uint160(Leader)).transfer(dc+dc+b);
            stateC=StateC.Done;
        }
        if(P.results(Leader)!=H&&P.results(follower)==H){
            address(uint160(follower)).transfer(dc+dc+b);
            stateC=StateC.Done;
        }
        if(P.results(Leader)!=H&&P.results(follower)!=H){
            address(uint160(Leader)).transfer(dc+b);
            address(uint160(follower)).transfer(dc);
            stateC=StateC.Done;
        }
        return true;
    }


    
}