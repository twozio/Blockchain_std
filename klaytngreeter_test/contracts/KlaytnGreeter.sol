// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
abstract contract Mortal {
    /* address 타입의 owner변수 정의 */
    address payable owner;
    /* 이 함수는 초기화 시점에 실행되어 컨트랙트 소유자를 설정합니다 */
    constructor () { owner = payable(msg.sender); }
    /* 컨트랙트에서 자금을 회수하는 함수 */
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

abstract contract KlaytnGreeter is Mortal {
    /* string 타입의 변수 greeting 정의 */
    string greeting;
    /* 이 함수는 컨트랙트가 생성될 딱 한번 실행됩니다 */
    constructor (string memory _greeting) {
        greeting = _greeting;
    }
    /* 주(Main) 함수 */
    function greet() public view returns (string memory) {
        return greeting;
    }
}