
pragma solidity ^0.4.0;
contract prisoners {

    address public client=0xEdDF494b84054aBFfDD4605b103eEAcDb1376bAa;
    address public audit=0x2b67CD470c47DF2F31610869807679f8Ca03A3a8;
    address public server=0xfdC6B9cB94549d604496dF69a23EE0C233361Ca7;
    address public TTP=0xbA33e64d5b4b8743918De93b2F7949756ff6B358;

    mapping (address => uint ) public results;
    mapping (address => bool ) public hasReg;
    mapping (address => bool ) public hasDeliver;
    //mapping (address => bool ) public Cheated;


    //uint public TTPR;


    //uint public T1;
    //uint public T2;
    //uint public T3;


    uint public w=1 ether;
    uint public h=1 ether;

    uint public f=1 ether;

    uint public d=2 ether;

    uint public c=10;

    uint public k1;
    uint public k2;
    uint public v;

    uint public balance;

    uint randNonce=0;


    enum State {INIT, Create, Prepare, Compute, Compare, Check, Error, Aborted,SendError}

    event CompareEvent(uint k1,uint k2,uint v,address audit,address sender,uint result1,uint result2);
    
    State public state = State.INIT;

    function() payable{

    }

    function Create () public payable returns(bool){
        assert(state==State.INIT);
        assert(msg.sender==client);
        assert(msg.value >= w+h);
        balance = msg.value;
        state=State.Create;
        if(hasReg[audit]==true&&hasReg[server]==true){
            state=State.Prepare;
        }
        return true;
    }

    function Register () public payable returns(bool){
        uint T =now;
        assert(state==State.Create);
        assert(msg.value==d);
        assert(!hasReg[msg.sender]);
        assert(msg.sender == audit || msg.sender == server);

        hasReg[msg.sender]=true;

        if (hasReg[audit]==true && hasReg[server]==true){
            state=State.Prepare;
        }
        return true;
    }

    function Task () payable returns(uint _k1,uint _k2,uint _v,uint _c){
        uint T=now;
        assert(state==State.Prepare);
        assert(msg.sender==audit);
        //assert(T<T1);

        k1=uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) %100;
        randNonce++;
        k2=uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) %100;
        randNonce++;
        v=uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) %100;
        randNonce++;
        state=State.Compute;
        return (k1,k2,v,c);
    }

    function Deliver (uint r) public payable returns (bool){
        uint T =now;
        assert(msg.sender==audit || msg.sender == server);
        assert(state==State.Compute);
        assert(!hasDeliver[msg.sender]);

        results[msg.sender]=r;
        hasDeliver[msg.sender]=true;
        if (hasDeliver[audit]==true && hasDeliver[server]==true){
            state=State.Compare;
        }
        
        return true;
    }

    function Pay() public payable returns (bool){
        assert(msg.sender==audit||msg.sender==server);
        assert(state==State.Compare);
        if (hasDeliver[audit]==true && hasDeliver[server]==true){
            if (results[audit]==results[server]){
                balance=balance-h-w;
                address(uint160(audit)).transfer(w);
                address(uint160(server)).transfer(h);
                if(balance>0){
                    state=State.Prepare;
                }
                else{
                    state=State.INIT;
                }
            }
            else{
                emit CompareEvent(k1,k2,v,audit,server,results[audit],results[server]);
                state=State.Check; 
            }
            hasDeliver[audit]=false;
            hasDeliver[server]=false;
        }
        
        return true;
    }
    
    function Check() public payable returns (bool){
        assert(msg.sender==client);
        assert(state==State.Compare);
        emit CompareEvent(k1,k2,v,audit,server,results[audit],results[server]);
        state=State.Check; 
    }

    function Response(address cheat,uint cheatn) public payable returns (bool){
        assert(msg.sender==TTP);
        assert(state==State.Check);
        if(cheatn==0){
            if (cheat==audit){
            address(uint160(TTP)).transfer(f);
            address(uint160(server)).transfer(h+d-f);
            state=State.INIT;
            hasReg[cheat]=false;
            }
        if(cheat==server){
            address(uint160(TTP)).transfer(f);
            address(uint160(audit)).transfer(w+d-f);
            state=State.INIT;
            hasReg[cheat]=false;
            }
        }
        if(cheatn==1){
            address(uint160(TTP)).transfer(f);
            state=State.INIT;
            hasReg[audit]=false;
            hasReg[server]=false;
        }
        hasDeliver[audit]=false;
        hasDeliver[server]=false;
        return true;
    }

    function reset()  public payable returns (bool){
        assert(msg.sender==client);
        if(hasReg[audit]==true && hasReg[server]==true){
            address(uint160(server)).transfer(d);
            address(uint160(audit)).transfer(d);
            hasReg[audit]=false;
            hasReg[server]=false;
        }
        uint256 bal=address(this).balance;
        address(uint160(client)).transfer(bal);
        return true;
    }
}