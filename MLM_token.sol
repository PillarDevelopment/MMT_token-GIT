pragma solidity ^0.4.13;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value)public returns (bool);
    function allowance(address owner, address spender)public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value)public returns (bool);
    function approve(address spender, uint256 value)public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) { // умножение
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) { //деление
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) { //вычитание
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) { // сложение
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20 {

    using SafeMath for uint256;
    mapping(address => uint256) balances;

    /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
    function transfer(address _to, uint256 _value)public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
    function balanceOf(address _owner)public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool) {
        uint _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value)public returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
    function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    function Ownable()public {
        owner = msg.sender;
    }

    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner)public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
    function mint(address _to, uint256 _amount)public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0, _to, _amount);
        return true;
    }

    /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
    function finishMinting()public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    /*function approveAndCall(address spender, uint skolko) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(skolko.mul(1000000000000000000));
        allowed[msg.sender][spender] = skolko;
        Approval(msg.sender, spender, skolko);
        Crowdsale(spender).receiveApproval(msg.sender, skolko, address(this));
        return true;
    }
  */

}

contract MultiLevelToken is MintableToken {

    string public constant name = "Multi-level token";
    string public constant symbol = "MLT";
    uint32 public constant decimals = 18;

}

contract Crowdsale is MultiLevelToken{ // заменил с Ownable

    using SafeMath for uint;

    address public multisig;
    uint public multisigPercent;
    address public bounty;
    uint public bountyPercent;

    MultiLevelToken public token = new MultiLevelToken(); // сощдается токен
    uint public rate;
    uint public tokens;
    uint public value;

    uint public tier; //видимо какой то уровень
    uint public i; // видимо просто переменная цикла for()тупо количество итераций
    uint public a=1;
    uint public b=1;
    uint public c=1;
    uint public d=1;
    uint public e=1;
    uint public parent; // для чего эта переменная??? - видимо какой то родитель - вышестоящий уровень
    uint256 public parentMoney; // родительские деньги
    address public whom; //кто  который
    mapping (uint => mapping(address => uint))public tree; //меппинг в которое записываются видимо адреса из ветки
    mapping (uint => mapping(uint => address))public order; // скорее всего покупки

    function Crowdsale()public {
        multisig = 0xCe66E79f59eafACaf4CaBaA317CaB4857487E3a1; // acc 2 ropsten
        multisigPercent = 5;
        bounty = 0x7eDE8260e573d3A3dDfc058f19309DF5a1f7397E; // acc 3 ropsten
        bountyPercent = 5;
        rate = 100000000000000000000; // 100 ether

    }

    function finishMinting() public onlyOwner returns(bool)  {
        token.finishMinting();
        return true;
    }

    function distribute() public{

        for (i=1;i<=10;i++){ // запускается цикл for
            while (parent >1){  // запускается цикл while если while == true // если родитель больше 1
                if (parent%3==0){ // условие - если родитель нацело делиться на 3
                    parent=parent.div(3);
                    whom = order[tier][parent]; // кто??
                    token.mint(whom,parentMoney); // выпускается токен кому и родительские деньги
                }
                else if ((parent-1)%3==0){
                    parent=(parent-1)/3;
                    whom = order[tier][parent];
                    token.mint(whom,parentMoney);
                }
                else{
                    parent=(parent+1)/3;
                    whom = order[tier][parent];
                    token.mint(whom,parentMoney);
                }
            }
        }

    }

    function createTokens()public  payable {

        uint _multisig = msg.value.mul(multisigPercent).div(100); // посчтитали 5%
        uint _bounty = msg.value.mul(bountyPercent).div(100); // посчтитали 5%
        tokens = rate.mul(msg.value).div(1 ether); // = 100 ether * value / 1 ether - количество токенов
        tokens = tokens.mul(55).div(100); // выпустили 55 токенов = что получилось * 55 / 100 получили 55 токенов
        parentMoney = msg.value.mul(35).div(10); // переменная род деньги = value * 55 / 10 - в 3,5 раза больше

        if (msg.value >= 50000000000000000 && msg.value < 100000000000000000){ // 0.05 - 0.1 Ether
            tier=1;
            tree[tier][msg.sender]=a;
            order[tier][a]=msg.sender;
            parent = a;
            a+=1;
            distribute();
        }
        else if (msg.value >= 100000000000000000 && msg.value < 200000000000000000){ // 0.1 - 0.2 ether
            tier=2;
            tree[tier][msg.sender]=b;
            order[tier][b]=msg.sender;
            parent = b;
            b+=1;
            distribute();
        }
        else if (msg.value >= 200000000000000000 && msg.value < 500000000000000000){ // 0.2 - 0.5 ether
            tier=3;
            tree[tier][msg.sender]=c;
            order[tier][c]=msg.sender;
            parent = c;
            c+=1;
            distribute();
        }
        else if(msg.value >= 500000000000000000 && msg.value < 1000000000000000000){ // 0.5 - 1 ether
            tier=4;
            tree[tier][msg.sender]=d;
            order[tier][d]=msg.sender;
            parent = d;
            d+=1;
            distribute();
        }
        else if(msg.value >= 1000000000000000000){ // больше чам 1 ether
            tier=5;
            tree[tier][msg.sender]=e;
            order[tier][e]=msg.sender;
            parent = e;
            e+=1;
            distribute();
        }
        token.mint(msg.sender, tokens); // выпуск токенов
        multisig.transfer(_multisig); // отправка средств мультисиг
        bounty.transfer(_bounty); // отправка средств баунти
    }

    /*address _tokenAddress;
    function GetTokenAddress (address Get) public onlyOwner{
        _tokenAddress=Get;
    }*/

    function receiveApproval(address from, uint skolko /*, address tokenAddress*/) public payable onlyOwner{
        //   require (tokenAddress == _tokenAddress);
        from.transfer(skolko.mul(1000000000000));
    }

    function() public payable { // при отправке эфира
        createTokens();
    }
    /*МОЯ функция для вывода эфира*/
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner
    {
        amount = amount; // убрал переменную DEC из оригинала
        _to.transfer(amount);
    }
}